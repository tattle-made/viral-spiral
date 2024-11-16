defmodule ViralSpiral.Entity.PlayerTest do
  alias ViralSpiral.Entity.Change
  alias ViralSpiral.Entity.Player
  use ExUnit.Case

  describe "struct" do
  end

  describe "changes" do
    setup do
      player = %Player{
        biases: %{red: 0, blue: 0},
        affinities: %{cat: 0, sock: 0},
        clout: 0
      }

      %{player: player}
    end

    test "change player clout", %{player: player} do
      new_player = Change.apply_change(player, nil, type: :clout, offset: 5)
      assert new_player.clout == 5
    end

    test "change player affinity", %{player: player} do
      new_player = Change.apply_change(player, nil, type: :affinity, target: :cat, offset: -2)
      assert new_player.affinities.cat == -2
    end

    test "change player bias", %{player: player} do
      new_player = Change.apply_change(player, nil, type: :bias, target: :red, offset: 9)
      assert new_player.biases.red == 9
    end
  end
end
