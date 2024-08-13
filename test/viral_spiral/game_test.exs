defmodule ViralSpira.GameTest do
  use ExUnit.Case
  alias ViralSpiral.Game.Player
  alias ViralSpiral.Game.Room

  describe "game" do
    test "room management" do
      room = Room.new()

      assert room.id != nil

      _players =
        [
          Player.new() |> Player.set_name("adhiraj"),
          Player.new() |> Player.set_name("aman"),
          Player.new() |> Player.set_name("krys"),
          Player.new() |> Player.set_name("farah")
        ]

      room = Room.set_state(room, :running)

      assert room.state == :running
    end
  end
end
