defmodule ViralSpiral.GameTest do
  use ExUnit.Case

  describe "card actions" do
    setup do
      game_state = Fixtures.initialized_game()
      %{state: game_state}
    end

    test "passing an affinity card", %{state: game_state} do
      players = game_state.player_map
      round = game_state.round
      turn = game_state.turn
      room_score = game_state.room_score
      player_scores = game_state.player_scores
    end
  end
end
