defmodule StateFixtures do
  alias ViralSpiral.Canon.Card.Sparse
  alias ViralSpiral.Room.State
  alias ViralSpiral.Entity.Room

  def new_state() do
    room = Room.reserve("test-room") |> Room.start(4)
    state = State.new(room, ["adhiraj", "krys", "aman", "farah"])

    state
  end

  def set_chaos(%State{} = root, chaos) do
    room = root.room
    new_room = %{room | chaos: chaos}
    Map.put(root, :room, new_room)
  end

  def player_by_names(%State{} = state) do
    players = state.players

    Map.keys(state.players)
    |> Enum.reduce(%{}, fn player_id, all ->
      Map.put(all, String.to_atom(players[player_id].name), players[player_id])
    end)
  end

  def active_cards(%State{} = state, player_id) do
    state.players[player_id].active_cards
  end

  @spec active_card(State.t(), String.t(), integer()) :: tuple() | nil
  def active_card(%State{} = state, player_id, ix) do
    case state.players[player_id].active_cards |> Enum.at(ix) do
      {id, veracity} -> Sparse.new({id, veracity})
      nil -> nil
    end
  end
end
