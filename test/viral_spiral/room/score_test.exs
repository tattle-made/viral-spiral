defmodule ViralSpiral.Game.ScoreTest do
  alias ViralSpiral.Game.Score.Player, as: PlayerScore
  alias ViralSpiral.Game.EngineConfig
  alias ViralSpiral.Game.Player
  use ExUnit.Case

  setup_all do
    room_config = %EngineConfig{}
    player = Player.new(room_config) |> Player.set_identity("yellow")
    player_score = PlayerScore.new(player, room_config)

    %{player: player, player_score: player_score}
  end

  test "player should not have a bias against their own identity", state do
    player_score = state.player_score

    assert Enum.find(player_score.biases, &(&1 == "yellow")) == nil
  end

  test "change player bias", state do
    player_score = state.player_score

    player_score = PlayerScore.change(player_score, :bias, :yellow, 3)
    assert player_score.biases.yellow == 3

    player_score = PlayerScore.change(player_score, :bias, :yellow, -2)
    assert player_score.biases.yellow == 1
  end

  test "change player affinity", state do
    player_score = state.player_score

    player_score = PlayerScore.change(player_score, :affinity, :cat, 5)
    assert player_score.affinities.cat == 5

    player_score = PlayerScore.change(player_score, :affinity, :cat, -2)
    assert player_score.affinities.cat == 3
  end

  test "change player clout", state do
    player_score = state.player_score

    player_score = PlayerScore.change(player_score, :clout, 3)
    assert player_score.clout == 3

    player_score = PlayerScore.change(player_score, :clout, -2)
    assert player_score.clout == 1
  end
end
