defmodule ViralSpiral.Room.Reducer do
  @moduledoc """

  """
  require IEx
  alias ViralSpiral.Room.CardDraw
  alias ViralSpiral.Canon.Card.Sparse
  alias ViralSpiral.Entity.Player.Changes.AddActiveCard
  alias ViralSpiral.Entity.Deck.Changes.RemoveCard
  alias ViralSpiral.Canon
  alias ViralSpiral.Room.Action
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
    CancelPlayerVote
  }

  alias ViralSpiral.Room.Actions.Engine.{DrawCard}

  # @spec reduce(State.t(), Action.t()) :: State.t()
  def reduce(%State{} = state, %{type: :draw_card, payload: %DrawCard{}} = action) do
    %{deck: deck} = state
    card_sets = deck.available_cards
    current_player = State.current_round_player(state)
    draw_constraints = State.draw_constraints(state)
    card_type = CardDraw.draw_type(draw_constraints)
    tgb = draw_constraints.tgb
    card = Canon.draw_card_from_deck(card_sets, card_type, tgb)

    # room_stats = State.stats(state)
    # card = DynamicCard.maybe_patch_headline(card, room_stats)

    changes = [
      {state.deck, %RemoveCard{card_sets: card_sets, card_type: card_type, card: card}},
      {
        state.players[current_player.id],
        %AddActiveCard{card: Sparse.new({card.id, elem(card_type, 1)})}
      }
    ]

    State.apply_changes(state, changes)
  end

  def reduce(%State{} = state, %Action{type: :pass_card} = action) do
    %{card: card, from_id: from_id, to_id: to_id} = action.payload
    card = state.deck.store[{card.id, card.veracity}]
    current_round_player = State.current_round_player(state)

    changes =
      Playable.pass(card, state, from_id, to_id) ++
        [
          {state.players[current_round_player.id], ChangeDescriptions.change_clout(1)},
          {state.players[from_id], ChangeDescriptions.remove_active(card.id, card.veracity)},
          {state.players[to_id], ChangeDescriptions.add_to_active(card.id, card.veracity)},
          {state.turn, ChangeDescriptions.pass_turn_to(to_id)}
        ]

    State.apply_changes(state, changes)
  end

  def reduce(%State{} = state, %{type: :discard_card} = action) do
  end

  def reduce(%State{} = state, %{type: :keep_card} = action) do
    %{player: from, card: card} = action.payload

    state =
      State.apply_changes(state, [
        {state.players[from], ChangeDescriptions.remove_active(card.id, card.veracity)},
        {state.round, [type: :next]},
        {state.players[from], [type: :add_to_hand, card: card]}
      ])

    State.apply_changes(state, [
      {state.turn, [type: :new, round: state.round]}
    ])
  end

  def reduce(%State{} = state, %Action{type: :mark_card_as_fake} = action) do
    %{from: from, card: card, turn: turn} = action.payload

    clout_penalty_change =
      if card.veracity == false,
        do: {state.players[Enum.at(turn.path, 1)], ChangeDescriptions.change_clout(-1)},
        else: {state.players[from.id], ChangeDescriptions.change_clout(-1)}

    State.apply_changes(state, [clout_penalty_change])

    # todo : will the card be kept/discarded at this point?
  end

  def reduce(%State{} = state, %{type: :create_room}) do
  end

  def reduce(%State{} = state, %{type: :join_room}) do
  end

  def reduce(%State{} = state, %{type: :start_game}) do
  end

  def reduce(%State{} = state, %{type: :view_source} = action) do
    %{from_id: from_id, card: card} = action.payload
    sparse_card = Sparse.new({card.id, card.veracity})
    article = Encyclopedia.get_article_by_card(state.deck.article_store, sparse_card)

    key = {from_id, card.id, card.veracity}

    source = %{}
    # source = %Source{
    #   owner: from_id,
    #   headline: article.headline,
    #   content: article.content,
    #   author: article.author,
    #   type: article.type
    # }

    state
    |> State.apply_changes([
      {state.power_check_source, [type: :put, key: key, source: source]}
    ])
  end

  def reduce(%State{} = state, %{type: :hide_source} = action) do
    %{card_id: card_id, card_veracity: card_veracity, player_id: player_id} = action.payload

    key = "#{player_id}_#{card_id}_#{card_veracity}"

    state
    |> State.apply_changes([
      {state.power_check_source, [type: :drop, key: key]}
    ])
  end

  def reduce(%State{} = state, %Action{type: :turn_card_to_fake} = action) do
    %{player_id: player_id, card: card} = action.payload

    # todo : only turn to fake if not already fake
    case card.veracity do
      true ->
        fake_card = state.deck.store[{card.id, false}]
        # todo add dynamic headline
        sparse_card = Sparse.new(fake_card.id, fake_card.veracity, fake_card.headline)

        changes = [
          {state.players[player_id], ChangeDescriptions.turn_to_fake(sparse_card)}
        ]

        State.apply_changes(state, changes)

      false ->
        raise "This card is already false"
    end
  end

  # def reduce(%State{} = state, %{type: :viral_spiral_pass, to: players} = action)
  #     when is_list(players) do
  #   card = action.payload.card

  #   changes = [
  #     {%PowerViralSpiral{}, ChangeDescriptions.PowerViralSpiral.set(players, card)}
  #   ]

  #   State.apply_changes(state, changes)
  # end

  # def reduce(%State{} = state, %{type: :viral_spiral_pass, to: player})
  #     when is_bitstring(player) do
  # end
end
