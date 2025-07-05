defmodule ViralSpiral.Entity.TurnTest do
  alias ViralSpiral.Entity.Turn.Change.SetPowerTrue
  alias ViralSpiral.Entity.Turn.Exception.IllegalPass
  alias ViralSpiral.Entity.Player
  alias ViralSpiral.Entity.Turn.Change.NextTurn
  alias ViralSpiral.Entity.Change
  alias ViralSpiral.Entity.Turn
  alias ViralSpiral.Entity.Round
  use ExUnit.Case

  describe "struct" do
    test "pass card" do
      players = [
        Player.new(%{id: "player_abc", biases: [:red, :yellow], affinities: [:cat, :sock]}),
        Player.new(%{id: "player_def", biases: [:red, :yellow], affinities: [:cat, :sock]}),
        Player.new(%{id: "player_ghi", biases: [:red, :yellow], affinities: [:cat, :sock]}),
        Player.new(%{id: "player_jkl", biases: [:red, :yellow], affinities: [:cat, :sock]})
      ]

      round = Round.new(players)
      turn = Turn.new(round)
      assert length(turn.pass_to) == 3

      current_player_id = Round.current_player_id(round)

      pass_to =
        players
        |> Enum.filter(&(&1.id != current_player_id))
        |> Enum.shuffle()
        |> Enum.take(1)
        |> Enum.at(0)

      turn = Turn.next(turn, pass_to.id)
      assert length(turn.pass_to) == 2

      assert_raise IllegalPass, fn ->
        Turn.next(turn, current_player_id)
      end
    end

    # test "pass card to multiple people during viral spiral special power" do
    #   game = Fixtures.initialized_game()
    #   players = game.players
    #   round = Round.new(players)
    #   turn = Turn.new(round)
    #   assert length(turn.pass_to) == 3

    #   _current_player = Enum.at(round.order, 0)
    #   to_pass_players = Enum.slice(round.order, 1..2)
    #   turn = Turn.next(turn, to_pass_players)

    #   assert length(turn) == 2
    #   assert length(Enum.at(turn, 0).pass_to) == 1
    # end
  end

  describe "changes" do
    setup do
      round = %Round{
        order: ["player_abc", "player_def", "player_ghi", "player_jkl"],
        count: 4,
        current: 0,
        skip: nil
      }

      turn = Turn.new(round)

      _current_player = Enum.at(round.order, 0)
      to_pass_player = Enum.at(round.order, 2)
      %{turn: turn, target: to_pass_player}
    end

    test "move to next turn", %{turn: turn, target: target} do
      turn = Change.change(turn, %NextTurn{target: "player_ghi"})
      assert turn.current == target
    end

    test "power", %{turn: turn} do
      assert turn.power == false
      turn = Change.change(turn, %SetPowerTrue{})
      assert turn.power == true
    end
  end
end
