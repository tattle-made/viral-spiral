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

    draw_type = action.payload.draw_type |> IO.inspect()
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

    changes =
      Playable.pass(card, state, from, to) ++
        [{state.players[to], ChangeDescriptions.add_to_active(card_id, veracity)}]

    State.apply_changes(state, changes)
  end

  def reduce(%State{} = state, %{type: :discard_card} = action) do
  end

  def reduce(%State{} = state, %{type: :keep_card} = action) do
  end

  def reduce(%State{} = state, %{type: :draw_card} = action) do
  end

  def reduce(%State{} = state, %{type: :create_room}) do
  end

  def reduce(%State{} = state, %{type: :join_room}) do
  end

  def reduce(%State{} = state, %{type: :start_game}) do
  end

  def reduce(%State{} = state, %{type: :check_source} = action) do
    card = action.payload.card
    player = action.payload.player

    article = state.deck.article_store
    article_entity = Factory.make_entity_article(article)

    changes = [
      {state.articles[player.id], ChangeDescriptions.set_article(card, article_entity)}
    ]

    State.apply_changes(state, changes)
  end

  def reduce(%State{} = state, %{type: :hide_source} = action) do
    # card = action.payload.card
    # player = action.payload.player

    # changes = [
    #   {state.articles[player.id], ChangeDescriptions.reset_article(card)}
    # ]

    # State.apply_changes(state, changes)
  end

  def reduce(%State{} = state, %{type: :turn_to_fake}) do
    # card = action.payload.card

    # changes = [
    #   # modify the player's active
    #   {state.players[player.id], ChangeDescriptions.turn_to_fake()}
    # ]
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
