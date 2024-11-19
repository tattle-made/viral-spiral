defmodule ViralSpiral.Room.Reducer do
  @moduledoc """

  """
  alias ViralSpiral.Gameplay.Factory
  alias ViralSpiral.Playable
  alias ViralSpiral.Room.State
  alias ViralSpiral.Room.ChangeOptions
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
        {state.deck, nil, ChangeOptions.remove_card(draw_type, draw_result)},
        {state.players[current_player.id], nil, ChangeOptions.add_to_active(draw_result.id)}
      ]

    State.apply_changes(state, changes)
  end

  def reduce(%State{} = state, %{type: pass_card} = action) do
    %{card: card_id, player: from, target: to} = action
    card = card_id
    # card = store[card_id]
    changes = Playable.pass(card, state, from, to)

    changes ++
      [
        {state.players[from], [type: :clout, offset: 1]},
        {state.players[from], [type: :bias, target: card.target, offset: 1]}
      ] ++
      (Map.keys(state.players)
       |> Enum.filter(&(state.players[&1].identity == card.target))
       |> Enum.map(&{state.players[&1], [type: :clout, offset: -1]}))
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
