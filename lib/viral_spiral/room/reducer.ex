defmodule ViralSpiral.Room.Reducer do
  @moduledoc """

  """
  alias ViralSpiral.Gameplay.Factory
  alias ViralSpiral.Playable
  alias ViralSpiral.Room.State
  alias ViralSpiral.Room.ChangeDescriptions
  alias ViralSpiral.Canon.DrawTypeRequirements
  alias ViralSpiral.Canon.Deck
  alias ViralSpiral.Room.Action

  @spec reduce(State.t(), Action.t()) :: State.t()
  def reduce(%State{} = state, %{type: :draw_card} = action) do
    draw_type = action.payload.draw_type

    current_player = State.current_round_player(state)

    sets = state.deck.available_cards
    draw_result = Deck.draw_card(sets, draw_type)

    changes =
      [
        {state.deck, ChangeDescriptions.remove_card(draw_type, draw_result)},
        {state.players[current_player.id], ChangeDescriptions.add_to_active(draw_result.id)}
      ]

    State.apply_changes(state, changes)
  end

  def reduce(%State{} = state, %{type: :pass_card} = action) do
    %{card: card_id, veracity: veracity, player: from, target: to} = action.payload
    card = state.deck.store[{card_id, veracity}]

    changes =
      Playable.pass(card, state, from, to) ++
        [{state.players[to], ChangeDescriptions.add_to_active(card_id)}]

    State.apply_changes(state, changes)
  end

  def reduce(%State{} = state, %{type: discard_card} = action) do
  end

  def reduce(%State{} = state, %{type: keep_card} = action) do
  end

  def reduce(%State{} = state, %{type: draw_card} = action) do
  end

  def reduce(%State{} = state, %{type: create_room}) do
  end

  def reduce(%State{} = state, %{type: join_room}) do
  end

  def reduce(%State{} = state, %{type: start_game}) do
  end
end
