defmodule ViralSpiral.Room.Reducer do
  @moduledoc """

  """
  alias ViralSpiral.Playable
  alias ViralSpiral.Room.State
  alias ViralSpiral.Room.ChangeOptions
  alias ViralSpiral.Canon.Deck.DrawTypeRequirements
  alias ViralSpiral.Canon.Deck
  alias ViralSpiral.Room.Action

  @spec reduce(State.t(), Action.t()) :: State.t()
  def reduce(%State{} = state, %{type: :draw_card}) do
    # todo : this is a hardcoded value, should be fixed later
    # this should be derivable from state.room

    requirements = %DrawTypeRequirements{
      tgb: 4,
      total_tgb: 10,
      biases: [:red, :yellow, :blue],
      affinities: [:skub, :highfive],
      current_player: %{
        identity: :blue
      }
    }

    # requirements = Factory.draw_type_requirements(state.room)
    current_player = State.current_player(state)
    sets = state.deck.available_cards
    type = Deck.draw_type(requirements)
    card_id = Deck.draw_card(sets, type) |> Map.get(:id)

    # IO.inspect(current_player)
    # IO.inspect(type)
    # IO.inspect(card_id)
    # IO.inspect("hello")

    changes =
      [
        {state.deck, nil, ChangeOptions.remove_card(type, card_id)}
      ]
      |> IO.inspect()

    # State.apply_changes(state, changes) |> IO.inspect()
    # [
    #   {state.deck, ChangeOptions.remove_card(type, card_id)},
    #   {state.players[current_player], ChangeOptions.add_to_active(card_id)}
    # ]
    # |> State.apply_changes()

    state
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
