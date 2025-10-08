defmodule ViralSpiral.Room.Reducer do
  @moduledoc """

  """
  require IEx
  alias ViralSpiral.Room.Actions
  alias ViralSpiral.Entity.Changes
  alias ViralSpiral.Room.StateTransformation
  alias ViralSpiral.Entity.Player
  alias ViralSpiral.Entity.Player.Changes.Bias
  alias ViralSpiral.Entity.Player.Changes.RemoveFromHand
  alias ViralSpiral.Entity.PowerViralSpiral.Changes.InitiateViralSpiral
  alias ViralSpiral.Room.Actions.Player.ViralSpiralInitiate
  alias ViralSpiral.Room
  alias ViralSpiral.Entity.PowerCancelPlayer.Changes.ResetCancel
  alias ViralSpiral.Entity.DynamicCard.Changes.AddIdentityStats

  alias ViralSpiral.Entity.Turn.Change.NewTurn
  alias ViralSpiral.Entity.Turn.Change.NextTurn
  alias ViralSpiral.Entity.Turn.Change.SetPowerTrue

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
    current_player = State.current_round_player(state)
    draw_constraints = State.draw_constraints(state)
    card_type = CardDraw.draw_type(draw_constraints)
    chaos = draw_constraints.chaos
    card = Canon.draw_card_from_deck(card_sets, card_type, chaos)

    sparse_card = Sparse.new(card.id, elem(card_type, 1))

    changes = [
      {state.deck, %RemoveCard{card_sets: card_sets, card_type: card_type, card: card}},
      {state.players[current_player.id], %AddActiveCard{card: sparse_card}}
    ]

    State.apply_changes(state, changes)
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
    card_type = {full_card.type, full_card.veracity, Map.get(full_card, :target)}

    changes = [
      {state.deck, %RemoveCard{card_sets: card_sets, card_type: card_type, card: card}},
      {state.players[current_player.id], %AddActiveCard{card: card}}
    ]

    State.apply_changes(state, changes)
  end

  def reduce(%State{} = state, %MarkAsFake{} = action) do
    %{from_id: from_id, card: card} = action
    turn = state.turn

    # todo fix this.
    clout_penalty_change =
      if card.veracity == false,
        do: [{state.players[Enum.at(turn.path, -1)], %Clout{offset: -1}}],
        else: [{state.players[from_id], %Clout{offset: -1}}]

    set_power_change = [{state.turn, %SetPowerTrue{}}]

    all_changes = clout_penalty_change ++ set_power_change

    with new_state <- State.apply_changes(state, all_changes),
         changes <- Changes.change(new_state, %DiscardCard{from_id: from_id, card: card}) do
      reduce(:discard_card, new_state, changes)
    end
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
    sparse_card = Sparse.new(card.id, card.veracity)

    can_turn_fake =
      StateTransformation.can_turn_fake(state, sparse_card) |> IO.inspect(label: "can turn fake")

    # todo : only turn to fake if not already fake
    case can_turn_fake do
      true ->
        card = Canon.get_card_from_store(sparse_card)
        identity_stats = State.identity_stats(state)

        dynamic_card_change =
          case DynamicCard.find_placeholders(card.fake_headline) do
            [] ->
              []

            _ ->
              [
                {state.dynamic_card,
                 %AddIdentityStats{card: sparse_card, identity_stats: identity_stats}}
              ]
          end

        set_power_change = [{state.turn, %SetPowerTrue{}}]

        all_changes = dynamic_card_change ++ set_power_change

        State.apply_changes(state, all_changes)

      false ->
        raise "This card has already been turned false"
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

      # {state.power_cancel_player, %VoteCancel{from_id: from_id, vote: true}},

      # todo : affinity offset needs to account for affinitie's polarity
      # atman's idea - take absolute and then add offset
      {state.players[from_id], %Affinity{target: affinity, offset: affinity_offset}}
    ]

    # If there is only one player (the initiator), don't count their vote, and take care of it VoteCancel reducer later.
    changes =
      if length(allowed_voters) > 1 do
        changes ++ [{state.power_cancel_player, %VoteCancel{from_id: from_id, vote: true}}]
      else
        changes
      end

    set_power_change = [{state.turn, %SetPowerTrue{}}]

    all_changes = changes ++ set_power_change

    state = State.apply_changes(state, all_changes)

    # If there is only one player (the initiator), initiate the
    # VoteCancel reducer (count vote of the current player and do further processing: calculating result and final state of the power)
    if length(allowed_voters) == 1 do
      action = Actions.vote_to_cancel(%{from_id: from_id, vote: true})
      reduce(state, action)
    else
      state
    end
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

  def reduce(%State{} = state, %ViralSpiralInitiate{} = action) do
    %{from_id: from_id, to_id: to_id, card: card} = action
    sparse_card = Sparse.new(card.id, card.veracity)
    full_card = Canon.get_card_from_store(sparse_card)
    sender = state.players[from_id]
    viralspiral_threshold = state.room.viral_spiral_threshold

    # power_change = [
    #   {
    #     state.power_viralspiral,
    #     %InitiateViralSpiral{from_id: from_id, to_id: to_id, card: sparse_card}
    #   }
    # ]
    clout_changes = [
      {state.players[from_id], %Clout{offset: length(to_id)}}
    ]

    card_pass_changes =
      to_id
      |> Enum.map(&Playable.pass(full_card, state, from_id, &1))
      |> List.flatten()

    hand_changes =
      to_id
      |> Enum.map(&{state.players[&1], %AddToHand{card: sparse_card}})
      |> List.flatten()

    sender_hand_change = [
      {state.players[from_id], %RemoveFromHand{card: sparse_card}}
    ]

    set_power_change = [{state.turn, %SetPowerTrue{}}]

    target_bias = Player.viralspiral_target_bias(sender, viralspiral_threshold)
    target_affinity = Player.viralspiral_target_affinity(sender, viralspiral_threshold)

    penalty_changes =
      case target_bias do
        nil ->
          case target_affinity do
            nil ->
              []

            affinity ->
              current = sender.affinities[affinity]
              offset = if current > 0, do: -1, else: 1
              [{state.players[from_id], %Affinity{target: affinity, offset: offset}}]
          end

        bias ->
          [{state.players[from_id], %Bias{target: bias, offset: -1}}]
      end

    all_changes =
      clout_changes ++
        card_pass_changes ++
        sender_hand_change ++ hand_changes ++ set_power_change ++ penalty_changes

    state = State.apply_changes(state, all_changes)
    State.apply_changes(state, Room.game_end_change(state))
  end

  def reduce(:pass_card, %State{} = state, changes) do
    state = State.apply_changes(state, changes)
    State.apply_changes(state, Room.game_end_change(state))
  end

  def reduce(:keep_card, %State{} = state, changes) do
    state = State.apply_changes(state, changes)

    State.apply_changes(state, [
      {state.turn, %NewTurn{round: state.round}}
    ])
    |> reduce(%DrawCard{})
  end

  def reduce(:discard_card, %State{} = state, changes) do
    state = State.apply_changes(state, changes)

    State.apply_changes(state, [
      {state.turn, %NewTurn{round: state.round}}
    ])
    |> reduce(%DrawCard{})
  end
end
