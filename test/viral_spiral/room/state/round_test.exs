defmodule ViralSpiral.Entity.RoundTest do
  alias ViralSpiral.Entity.Change
  alias ViralSpiral.Entity.Round
  use ExUnit.Case

  describe "round progression" do
    test "round progress" do
      %{players: players} = Fixtures.initialized_game()
      round = Round.new(players)
      assert round.current == 0

      round = Round.next(round)
      assert round.current == 1

      round = Round.next(round)
      assert round.current == 2

      round = Round.next(round)
      assert round.current == 3

      round = Round.next(round)
      assert round.current == 0
    end
  end

  describe "skip player in a round" do
    test "if the player hasn't had their turn in this round, skip them in the current round itself" do
      %{players: players} = Fixtures.initialized_game()
      round = Round.new(players)
      player_order = round.order
      to_skip = Enum.at(player_order, 2)

      assert round.current == 0
      round = Round.add_skip(round, to_skip)
      round = Round.next(round)
      assert round.current == 1

      round = Round.next(round)
      assert round.current == 3
    end

    test "if the player has had their turn in the active round, skip their turn in the next round" do
      %{players: players} = Fixtures.initialized_game()
      round = Round.new(players)
      player_order = round.order

      assert round.current == 0
      round = Round.next(round)
      assert round.current == 1
      round = Round.next(round)
      assert round.current == 2

      to_skip = Enum.at(player_order, 1)
      round = Round.add_skip(round, to_skip)
      round = Round.next(round)
      assert round.current == 3

      round = Round.next(round)
      assert round.current == 0

      round = Round.next(round)
      assert round.current == 2

      round = Round.next(round)
      assert round.current == 3

      round = Round.next(round)
      assert round.current == 0

      round = Round.next(round)
      assert round.current == 1
    end
  end

  describe "changes" do
    setup do
      players = Fixtures.players()
      round = Round.new(players)
      %{round: round}
    end

    test "move to next round", %{round: round} do
      new_round = Change.apply_change(round, nil, type: :next)
      assert new_round.current == 1
    end
  end
end
