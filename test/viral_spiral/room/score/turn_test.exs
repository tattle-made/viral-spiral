defmodule ViralSpiral.Room.State.TurnTest do
  alias ViralSpiral.Room.State.Turn
  alias ViralSpiral.Room.State.Round
  use ExUnit.Case

  describe "turn progression" do
    test "pass card" do
      game = Fixtures.initialized_game()
      player_list = game.player_list
      round = Round.new(player_list)
      turn = Turn.new(round)
      assert length(turn.pass_to) == 3

      current_player = Enum.at(round.order, round.current)

      pass_to =
        Enum.filter(player_list, &(&1.id != current_player))
        |> Enum.shuffle()
        |> Enum.take(1)
        |> Enum.at(0)

      turn = Turn.next(turn, pass_to.id)
      assert length(turn.pass_to) == 2
    end

    @tag timeout: :infinity
    test "pass card to multiple people during viral spiral special power" do
      game = Fixtures.initialized_game()
      player_list = game.player_list
      round = Round.new(player_list)
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
  end
end
