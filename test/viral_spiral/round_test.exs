defmodule ViralSpiral.RoundTest do
  alias ViralSpiral.Game.Round
  use ExUnit.Case

  test "round progress" do
    %{player_list: player_list} = Fixtures.initialized_game()
    round = Round.new(player_list)
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

  describe "skip player in a round" do
    test "if the player hasn't had their turn in this round, skip them in the current round itself" do
      %{player_list: player_list} = Fixtures.initialized_game()
      round = Round.new(player_list)
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
      %{player_list: player_list} = Fixtures.initialized_game()
      round = Round.new(player_list)
      player_order = round.order

      assert round.current == 0
      round = Round.next(round)
      assert round.current == 1
      round = Round.next(round)
      assert round.current == 2

      to_skip = Enum.at(player_order, 1)
      round = Round.add_skip(round, to_skip)
      # assert round.skip.round == :next
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
end
