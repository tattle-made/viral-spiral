defmodule ViralSpiral.Game.ScoreTest do
  alias ViralSpiral.Entity.Player
  alias ViralSpiral.Room.EngineConfig
  use ExUnit.Case

  setup_all do
    engine_config = %EngineConfig{}
    player = Player.new(engine_config) |> Player.set_identity("yellow")

    %{player: player}
  end

  test "player should not have a bias against their own identity", state do
    player = state.player

    assert Enum.find(player.biases, &(&1 == "yellow")) == nil
  end

  test "change player bias", state do
    player = state.player

    player = Player.change(player, :bias, :yellow, 3)
    assert player.biases.yellow == 3

    player = Player.change(player, :bias, :yellow, -2)
    assert player.biases.yellow == 1
  end

  test "change player affinity", state do
    player = state.player

    player = Player.change(player, :affinity, :cat, 5)
    assert player.affinities.cat == 5

    player = Player.change(player, :affinity, :cat, -2)
    assert player.affinities.cat == 3
  end

  test "change player clout", state do
    player = state.player

    player = Player.change(player, :clout, 3)
    assert player.clout == 3

    player = Player.change(player, :clout, -2)
    assert player.clout == 1
  end
end
