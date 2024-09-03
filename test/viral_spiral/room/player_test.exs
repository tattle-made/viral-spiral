defmodule ViralSpiral.Game.PlayerTest do
  alias ViralSpiral.Game.Player
  alias ViralSpiral.Game.EngineConfig
  use ExUnit.Case

  test "create player from room config" do
    room_config = %EngineConfig{}

    player =
      Player.new(room_config)
      |> Player.set_name("adhiraj")

    assert player.name == "adhiraj"
  end
end
