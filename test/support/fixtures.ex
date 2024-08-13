defmodule Fixtures do
  alias ViralSpiral.Game.Player
  alias ViralSpiral.Game.Room
  alias ViralSpiral.Game

  def initialized_game() do
    player_list = [
      Player.new() |> Player.set_name("adhiraj"),
      Player.new() |> Player.set_name("aman"),
      Player.new() |> Player.set_name("krys"),
      Player.new() |> Player.set_name("farah")
    ]

    players = Enum.reduce(player_list, %{}, fn player, acc -> Map.put(acc, player.id, player) end)

    %Game{
      room: Room.new(),
      player_map: players,
      player_list: player_list
    }
  end
end
