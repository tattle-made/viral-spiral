defmodule ViralSpiral.Entity.RoundTest do
  alias ViralSpiral.Entity.Round.Changes.SkipRound
  alias ViralSpiral.Entity.Round.Changes.NextRound
  alias ViralSpiral.Room.ChangeDescriptions
  alias ViralSpiral.Entity.Change
  alias ViralSpiral.Entity.Round
  use ExUnit.Case

  @tag :skip
  describe "round progression" do
    test "round progress" do
      round =
        Round.new([
          %{id: "player_abc"},
          %{id: "player_def"},
          %{id: "player_ghi"},
          %{id: "player_jkl"}
        ])

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

  @tag :skip
  describe "skip player in a round" do
    setup do
      round =
        Round.new([
          %{id: "player_abc"},
          %{id: "player_def"},
          %{id: "player_ghi"},
          %{id: "player_jkl"}
        ])

      %{round: round}
    end

    test "if the player hasn't had their turn in this round, skip them in the current round itself",
         %{round: round} do
      player_order = round.order
      to_skip = Enum.at(player_order, 2)

      assert round.current == 0
      round = Round.add_skip(round, to_skip)
      round = Round.next(round)
      assert round.current == 1

      round = Round.next(round)
      assert round.current == 3
    end

    test "if the player has had their turn in the active round, skip their turn in the next round",
         %{round: round} do
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

  @tag :skip
  describe "changes" do
    setup do
      round =
        Round.new([
          %{id: "player_abc"},
          %{id: "player_def"},
          %{id: "player_ghi"},
          %{id: "player_jkl"}
        ])

      %{round: round}
    end

    test "move to next round", %{round: round} do
      new_round = Change.change(round, %NextRound{})
      assert new_round.current == 1

      new_round = Change.change(new_round, %NextRound{})
      assert new_round.current == 2
    end

    test "skip a player's round", %{round: round} do
      new_round = Change.change(round, %SkipRound{player_id: "player_def"})
      assert new_round.skip.player == "player_def"
    end
  end
end
