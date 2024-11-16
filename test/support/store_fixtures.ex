defmodule StoreFixtures do
  alias ViralSpiral.Room.State.Root
  alias ViralSpiral.Room.State.Room

  def new_store() do
    room = Room.reserve("test-room") |> Room.start(4)
    state = Root.new(room, ["adhiraj", "krys", "aman", "farah"])

    state
  end

  def set_chaos(%Root{} = root, chaos) do
    room = root.room
    new_room = %{room | chaos: chaos}
    Map.put(root, :room, new_room)
  end

  def player_by_names(%Root{} = root) do
    players = root.players

    Map.keys(root.players)
    |> Enum.reduce(%{}, fn player_id, all ->
      Map.put(all, String.to_atom(players[player_id].name), players[player_id])
    end)
  end

  def current_round(%Root{} = root) do
  end

  def current_turn(%Root{} = root) do
  end
end
