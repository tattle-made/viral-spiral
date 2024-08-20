defmodule ViralSpiral.GameTest do
  alias ViralSpiral.Game
  use ExUnit.Case

  describe "card actions" do
    setup do
      game_state = Fixtures.initialized_game()
      %{state: game_state}
    end

    test "passing an affinity card changes the player's clout and affinity", %{state: game_state} do
      players = game_state.player_map
      round = game_state.round
      turn = game_state.turn
      room_score = game_state.room_score
      player_scores = game_state.player_scores

      card = Fixtures.card_affinity()

      current_player = players[turn.current]
      target_player = players[2]

      Game.pass_card(game_state, card, current_player, target_player)

      IO.inspect(game_state)
      # IO.inspect(card)
    end
  end
end
