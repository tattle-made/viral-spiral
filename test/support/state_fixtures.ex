defmodule StateFixtures do
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

  def player_by_names(%State{} = root) do
    players = root.players

    Map.keys(root.players)
    |> Enum.reduce(%{}, fn player_id, all ->
      Map.put(all, String.to_atom(players[player_id].name), players[player_id])
    end)
  end

  def current_round(%State{} = root) do
  end

  def current_turn(%State{} = root) do
  end
end
