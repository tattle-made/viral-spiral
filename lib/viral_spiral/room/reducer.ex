defmodule ViralSpiral.Room.Reducer do
  @moduledoc """

  """
  alias ViralSpiral.Entity.PowerViralSpiral
  alias ViralSpiral.Canon.Encyclopedia
  alias ViralSpiral.Room.Factory
  alias ViralSpiral.Playable
  alias ViralSpiral.Room.State
  alias ViralSpiral.Room.ChangeDescriptions
  alias ViralSpiral.Canon.DrawTypeRequirements
  alias ViralSpiral.Canon.Deck
  alias ViralSpiral.Room.Action

  # @spec reduce(State.t(), Action.t()) :: State.t()
  def reduce(%State{} = state, %{type: :draw_card} = action) do
    current_player = State.current_round_player(state)

    draw_type = action.payload.draw_type
    sets = state.deck.available_cards
    draw_result = Deck.draw_card(sets, draw_type)

    changes =
      [
        {state.deck, ChangeDescriptions.remove_card(draw_type, draw_result)},
        {state.players[current_player.id],
         ChangeDescriptions.add_to_active(draw_result.id, draw_type[:veracity])}
      ]

    State.apply_changes(state, changes)
  end

  def reduce(%State{} = state, %{type: :pass_card} = action) do
    %{card: card_id, veracity: veracity, player: from, target: to} = action.payload
    card = state.deck.store[{card_id, veracity}]
    current_round_player = State.current_round_player(state)

    changes =
      Playable.pass(card, state, from, to) ++
        [
          {state.players[current_round_player.id], ChangeDescriptions.change_clout(1)},
          {state.players[from], ChangeDescriptions.remove_active(card_id, veracity)},
          {state.players[to], ChangeDescriptions.add_to_active(card_id, veracity)},
          {state.turn, ChangeDescriptions.pass_turn_to(to)}
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

  def reduce(%State{} = state, %{type: :draw_card} = action) do
  end

  def reduce(%State{} = state, %{type: :create_room}) do
  end

  def reduce(%State{} = state, %{type: :join_room}) do
  end

  def reduce(%State{} = state, %{type: :start_game}) do
  end

  def reduce(%State{} = state, %{type: :view_source} = action) do
    %{card: card, player_id: player_id} = action.payload

    article_store = state.deck.article_store
    article = Encyclopedia.get_article_by_card(article_store, card)
    article_entity = Factory.make_entity_article(article)

    %{
      state
      | articles: Map.put(state.articles, {player_id, card}, article_entity)
    }
  end

  def reduce(%State{} = state, %{type: :hide_source} = action) do
    %{card: card, player_id: player_id} = action.payload

    %{
      state
      | articles: Map.delete(state.articles, {player_id, card})
    }
  end

  def reduce(%State{} = state, %Action{type: :turn_card_to_fake} = action) do
    %{player_id: player_id} = action.payload

    changes = [
      {state.players[player_id], ChangeDescriptions.turn_to_fake(action)}
    ]

    State.apply_changes(state, changes)
  end

  def reduce(%State{} = state, %{type: :viral_spiral_pass, to: players} = action)
      when is_list(players) do
    card = action.payload.card

    changes = [
      {%PowerViralSpiral{}, ChangeDescriptions.PowerViralSpiral.set(players, card)}
    ]

    State.apply_changes(state, changes)
  end

  def reduce(%State{} = state, %{type: :viral_spiral_pass, to: player})
      when is_bitstring(player) do
  end
end
