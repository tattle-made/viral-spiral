defmodule ViralSpiral.Entity.TurnTest do
  alias ViralSpiral.Entity.Change
  alias ViralSpiral.Entity.Turn
  alias ViralSpiral.Entity.Round
  use ExUnit.Case

  describe "turn progression" do
    @tag timeout: :infinity
    test "pass card" do
      game = Fixtures.initialized_game()
      players = game.players
      round = Round.new(players)
      turn = Turn.new(round)
      assert length(turn.pass_to) == 3

      current_player = Enum.at(round.order, round.current)

      pass_to =
        Map.keys(players)
        |> Enum.filter(&(&1 != current_player))
        |> Enum.shuffle()
        |> Enum.take(1)
        |> Enum.at(0)

      turn = Turn.next(turn, pass_to)
      assert length(turn.pass_to) == 2
    end

    @tag timeout: :infinity
    test "pass card to multiple people during viral spiral special power" do
      game = Fixtures.initialized_game()
      players = game.players
      round = Round.new(players)
      turn = Turn.new(round)
      assert length(turn.pass_to) == 3

      _current_player = Enum.at(round.order, 0)
      to_pass_players = Enum.slice(round.order, 1..2)
      turn = Turn.next(turn, to_pass_players)

      assert length(turn) == 2
      assert length(Enum.at(turn, 0).pass_to) == 1
    end
  end

  describe "changes" do
    setup do
      players = Fixtures.players()
      round = Round.new(players)
      turn = Turn.new(round)

      current_player = Enum.at(round.order, 0)
      to_pass_player = Enum.at(round.order, 2)
      %{turn: turn, target: to_pass_player}
    end

    test "move to next turn", %{turn: turn, target: target} do
      new_turn = Change.apply_change(turn, type: :next, target: target)
      assert new_turn.current == target
    end
  end
end
