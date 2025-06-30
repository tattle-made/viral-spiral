defmodule ViralSpiral.Room.Reducer do
  @moduledoc """

  """
  require IEx
  alias ViralSpiral.Entity.PowerCancelPlayer.Changes.ResetCancel
  alias ViralSpiral.Entity.DynamicCard.Changes.AddIdentityStats

  alias ViralSpiral.Entity.Turn.Change.NewTurn
  alias ViralSpiral.Entity.Turn.Change.NextTurn

  alias ViralSpiral.Entity.Round.Changes.NextRound
  alias ViralSpiral.Entity.Round.Changes.SkipRound
  alias ViralSpiral.Entity.Room.{Changes.ReserveRoom, Changes.JoinRoom, Changes.StartGame}
  alias ViralSpiral.Entity.PowerCancelPlayer.Changes.VoteCancel
  alias ViralSpiral.Entity.PowerCancelPlayer.Changes.InitiateCancel
  alias ViralSpiral.Canon.DynamicCard

  alias ViralSpiral.Entity.Player.Changes.AddToHand
  alias ViralSpiral.Entity.Player.Changes.MakeActiveCardFake
  alias ViralSpiral.Entity.Player.Changes.CloseArticle
  alias ViralSpiral.Entity.Player.Changes.ViewArticle
  alias ViralSpiral.Entity.Player.Changes.Affinity
  alias ViralSpiral.Entity.Player.Changes.RemoveActiveCard
  alias ViralSpiral.Entity.Player.Changes.Clout

  alias ViralSpiral.Room.Playable
  alias ViralSpiral.Room.CardDraw

  alias ViralSpiral.Canon.Card.Sparse
  alias ViralSpiral.Entity.Player.Changes.AddActiveCard
  alias ViralSpiral.Entity.Deck.Changes.RemoveCard
  alias ViralSpiral.Canon
  alias ViralSpiral.Room.State

  alias ViralSpiral.Room.Actions.Player.{
    ReserveRoom,
    JoinRoom,
    StartGame,
    KeepCard,
    PassCard,
    DiscardCard,
    MarkAsFake,
    ViewSource,
    CancelPlayerInitiate,
    CancelPlayerVote,
    TurnToFake,
    HideSource
  }

  alias ViralSpiral.Room.Actions.Engine.{DrawCard}

  def reduce(%State{} = state, %ReserveRoom{} = action) do
    alias ViralSpiral.Entity.Room.Changes.ReserveRoom

    %{player_name: player_name} = action

    changes = [
      {state.room, %ReserveRoom{player_name: player_name}}
    ]

    State.apply_changes(state, changes)
  end

  def reduce(%State{} = state, %JoinRoom{} = action) do
    alias ViralSpiral.Entity.Room.Changes.JoinRoom

    %{player_name: player_name} = action

    changes = [
      {state.room, %JoinRoom{player_name: player_name}}
    ]

    State.apply_changes(state, changes)
  end

  def reduce(%State{} = state, %StartGame{}) do
    alias ViralSpiral.Entity.Room.Changes.StartGame

    changes = [
      {state.room, %StartGame{}}
    ]

    state = State.apply_changes(state, changes)
    state |> State.setup()
  end

  def reduce(%State{} = state, %DrawCard{card: nil}) do
    %{deck: deck} = state
    card_sets = deck.available_cards
    card_store = Canon.get_card_store()
    current_player = State.current_round_player(state)
    draw_constraints = State.draw_constraints(state)
    card_type = CardDraw.draw_type(draw_constraints)
    chaos = draw_constraints.chaos
    card = Canon.draw_card_from_deck(card_sets, card_type, chaos)

    full_card = card_store[Sparse.new(card.id, elem(card_type, 1))]
    sparse_card = Sparse.new(card.id, elem(card_type, 1))
    identity_stats = State.identity_stats(state)

    dynamic_card_change =
      case DynamicCard.find_placeholders(full_card.headline) do
        [] ->
          []

        _ ->
          [
            {state.dynamic_card,
             %AddIdentityStats{card: sparse_card, identity_stats: identity_stats}}
          ]
      end

    changes = [
      {state.deck, %RemoveCard{card_sets: card_sets, card_type: card_type, card: card}},
      {state.players[current_player.id], %AddActiveCard{card: sparse_card}}
    ]

    all_changes = dynamic_card_change ++ changes
    State.apply_changes(state, all_changes)
  end

  @doc """
  This is used for testing when we want to explicitly draw a specific card
  """
  def reduce(%State{} = state, %DrawCard{card: card}) do
    %{deck: deck} = state
    card_sets = deck.available_cards
    card_store = Canon.get_card_store()
    current_player = State.current_round_player(state)
    full_card = card_store[card]
    identity_stats = State.identity_stats(state)
    card_type = {full_card.type, full_card.veracity, Map.get(full_card, :target)}

    dynamic_card_change =
      case DynamicCard.find_placeholders(full_card.headline) do
        [] ->
          []

        _ ->
          [
            {state.dynamic_card, %AddIdentityStats{card: card, identity_stats: identity_stats}}
          ]
      end

    changes = [
      {state.deck, %RemoveCard{card_sets: card_sets, card_type: card_type, card: card}},
      {state.players[current_player.id], %AddActiveCard{card: card}}
    ]

    all_changes = dynamic_card_change ++ changes
    State.apply_changes(state, all_changes)
  end

  def reduce(%State{} = state, %PassCard{} = action) do
    %{card: card, from_id: from_id, to_id: to_id} = action
    sparse_card = Sparse.new(card.id, card.veracity)
    card = Canon.get_card_from_store(sparse_card)

    identity_stats = State.identity_stats(state)
    card = DynamicCard.patch(card, identity_stats)

    changes =
      Playable.pass(card, state, from_id, to_id) ++
        [
          {state.players[from_id], %RemoveActiveCard{card: sparse_card}},
          {state.players[to_id], %AddActiveCard{card: sparse_card}},
          {state.turn, %NextTurn{target: to_id}}
        ]

    State.apply_changes(state, changes)
  end

  def reduce(%State{} = state, %KeepCard{} = action) do
    %{from_id: from_id, card: card} = action
    sparse_card = Sparse.new(card.id, card.veracity)
    card = Canon.get_card_from_store(sparse_card)

    changes =
      Playable.keep(card, state, from_id) ++
        [
          {state.players[from_id], %RemoveActiveCard{card: sparse_card}},
          {state.players[from_id], %AddToHand{card: sparse_card}},
          {state.round, %NextRound{}}
        ]

    state = State.apply_changes(state, changes)

    State.apply_changes(state, [
      {state.turn, %NewTurn{round: state.round}}
    ])
    |> reduce(%DrawCard{})
  end

  def reduce(%State{} = state, %DiscardCard{} = action) do
    %{from_id: from_id, card: card} = action
    sparse_card = Sparse.new(card.id, card.veracity)
    card = Canon.get_card_from_store(sparse_card)

    changes =
      Playable.discard(card, state, from_id) ++
        [
          {state.players[from_id], %RemoveActiveCard{card: sparse_card}},
          {state.round, %NextRound{}}
        ]

    state = State.apply_changes(state, changes)

    State.apply_changes(state, [
      {state.turn, %NewTurn{round: state.round}}
    ])
    |> reduce(%DrawCard{})
  end

  def reduce(%State{} = state, %MarkAsFake{} = action) do
    %{from_id: from_id, card: card} = action
    turn = state.turn

    clout_penalty_change =
      if card.veracity == false,
        do: {state.players[Enum.at(turn.path, -1)], %Clout{offset: -1}},
        else: {state.players[from_id], %Clout{offset: -1}}

    State.apply_changes(state, [clout_penalty_change])
    |> reduce(%DiscardCard{from_id: from_id, card: card})
  end

  def reduce(%State{} = state, %{type: :create_room}) do
  end

  def reduce(%State{} = state, %{type: :join_room}) do
  end

  def reduce(%State{} = state, %{type: :start_game}) do
  end

  def reduce(%State{} = state, %ViewSource{} = action) do
    %{from_id: from_id, card: card} = action
    sparse_card = Sparse.new(card.id, card.veracity)
    article = Canon.get_article_from_store(sparse_card)

    changes = [
      {state.players[from_id], %ViewArticle{card: sparse_card, article: article}}
    ]

    State.apply_changes(state, changes)
  end

  def reduce(%State{} = state, %HideSource{} = action) do
    %{from_id: from_id, card: card} = action
    sparse_card = Sparse.new(card.id, card.veracity)

    changes = [
      {state.players[from_id], %CloseArticle{card: sparse_card}}
    ]

    State.apply_changes(state, changes)
  end

  def reduce(%State{} = state, %TurnToFake{} = action) do
    %{from_id: from_id, card: card} = action

    # todo : only turn to fake if not already fake
    case card.veracity do
      true ->
        fake_card = Canon.get_card_from_store(Sparse.new(card.id, false))
        sparse_card = Sparse.new(fake_card.id, fake_card.veracity)
        identity_stats = State.identity_stats(state)

        changes = [
          {state.players[from_id], %MakeActiveCardFake{card: sparse_card}}
        ]

        dynamic_card_change =
          case DynamicCard.find_placeholders(fake_card.headline) do
            [] ->
              []

            _ ->
              [
                {state.dynamic_card,
                 %AddIdentityStats{card: sparse_card, identity_stats: identity_stats}}
              ]
          end

        all_changes = changes ++ dynamic_card_change

        State.apply_changes(state, all_changes)

      false ->
        raise "This card is already false"
    end
  end

  def reduce(%State{} = state, %CancelPlayerInitiate{} = action) do
    alias ViralSpiral.Entity.Player.Changes.Affinity

    %{from_id: from_id, target_id: target_id, affinity: affinity} =
      action

    polarity =
      case state.players[from_id].affinities[affinity] > 0 do
        true -> :positive
        false -> :negative
      end

    allowed_voters =
      Map.keys(state.players)
      |> then(fn players ->
        case polarity do
          :positive -> players |> Enum.filter(&(state.players[&1].affinities[affinity] > 0))
          :negative -> players |> Enum.filter(&(state.players[&1].affinities[affinity] < 0))
        end
      end)

    affinity_offset =
      case state.players[from_id].affinities[affinity] > 0 do
        true -> -1
        false -> 1
      end

    changes = [
      {state.power_cancel_player,
       %InitiateCancel{
         from_id: from_id,
         to_id: target_id,
         affinity: affinity,
         allowed_voters: allowed_voters
       }},
      {state.power_cancel_player, %VoteCancel{from_id: from_id, vote: true}},
      # todo : affinity offset needs to account for affinitie's polarity
      # atman's idea - take absolute and then add offset
      {state.players[from_id], %Affinity{target: affinity, offset: affinity_offset}}
    ]

    State.apply_changes(state, changes)
  end

  def reduce(%State{} = state, %CancelPlayerVote{} = action) do
    %{from_id: from_id, vote: vote} = action

    changes = [{state.power_cancel_player, %VoteCancel{from_id: from_id, vote: vote}}]
    state = State.apply_changes(state, changes)

    if state.power_cancel_player.result == true do
      changes = [
        {state.round, %SkipRound{player_id: state.power_cancel_player.target}},
        {state.power_cancel_player, %ResetCancel{}}
      ]

      State.apply_changes(state, changes)
    else
      state
    end
  end

  # def reduce(%State{} = state, %{type: :viral_spiral_pass, to: players} = action)
  #     when is_list(players) do
  #   card = action.card

  #   changes = [
  #     {%PowerViralSpiral{}, ChangeDescriptions.PowerViralSpiral.set(players, card)}
  #   ]

  #   State.apply_changes(state, changes)
  # end

  # def reduce(%State{} = state, %{type: :viral_spiral_pass, to: player})
  #     when is_bitstring(player) do
  # end
end
