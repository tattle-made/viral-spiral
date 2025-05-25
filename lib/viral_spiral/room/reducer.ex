defmodule ViralSpiral.Room.Reducer do
  @moduledoc """

  """
  require IEx
  alias ViralSpiral.Entity.Player.Changes.CloseArticle
  alias ViralSpiral.Entity.Player.Changes.ViewArticle
  alias ViralSpiral.Entity.Player.Changes.Affinity
  alias ViralSpiral.Entity.Turn.Change.NextTurn
  alias ViralSpiral.Entity.Player.Changes.RemoveActiveCard
  alias ViralSpiral.Entity.Player.Changes.Clout
  alias ViralSpiral.Room.Playable
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
    sparse_card = Sparse.new(card.id, card.veracity)
    card = state.deck.store[sparse_card]

    changes =
      Playable.pass(card, state, from_id, to_id) ++
        [
          {state.players[from_id], %RemoveActiveCard{card: sparse_card}},
          {state.players[to_id], %AddActiveCard{card: sparse_card}},
          {state.turn, %NextTurn{target: to_id}}
        ]

    State.apply_changes(state, changes)
  end

  def reduce(%State{} = state, %{type: :discard_card} = action) do
  end

  def reduce(%State{} = state, %{type: :keep_card} = action) do
    %{player: from, card: card} = action.payload

    state =
      State.apply_changes(state, [
        {state.players[from], %RemoveActiveCard{card: card}},
        {state.round, [type: :next]},
        {state.players[from], [type: :add_to_hand, card: card]}
      ])

    State.apply_changes(state, [
      {state.turn, [type: :new, round: state.round]}
    ])
  end

  def reduce(%State{} = state, %Action{type: :mark_card_as_fake} = action) do
    %{from_id: from_id, card: card} = action.payload
    turn = state.turn

    clout_penalty_change =
      if card.veracity == false,
        do: {state.players[Enum.at(turn.path, 1)], %Clout{offset: -1}},
        else: {state.players[from_id], %Clout{offset: -1}}

    State.apply_changes(state, [clout_penalty_change])
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
    article = Canon.get_article(state.deck.article_store, sparse_card)

    changes = [
      {state.players[from_id], %ViewArticle{card: sparse_card, article: article}}
    ]

    State.apply_changes(state, changes)
  end

  def reduce(%State{} = state, %{type: :hide_source} = action) do
    %{from_id: from_id, card: card} = action.payload
    sparse_card = Sparse.new({card.id, card.veracity})

    changes = [
      {state.players[from_id], %CloseArticle{card: sparse_card}}
    ]

    State.apply_changes(state, changes)
  end

  def reduce(%State{} = state, %Action{type: :turn_card_to_fake} = action) do
    %{player_id: player_id, card: card} = action.payload

    # todo : only turn to fake if not already fake
    # case card.veracity do
    #   true ->
    #     fake_card = state.deck.store[{card.id, false}]
    #     # todo add dynamic headline
    #     sparse_card = Sparse.new(fake_card.id, fake_card.veracity, fake_card.headline)

    #     changes = [
    #       {state.players[player_id],  ChangeDescriptions.turn_to_fake(sparse_card)}
    #     ]

    #     State.apply_changes(state, changes)

    #   false ->
    #     raise "This card is already false"
    # end
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
