defmodule ViralSpiral.PlayableTest do
  alias ViralSpiral.Room.State.Root
  alias ViralSpiral.Playable
  alias ViralSpiral.Affinity
  alias ViralSpiral.Canon.Deck
  use ExUnit.Case

  describe "affinity cards" do
    setup do
      game = Fixtures.initialized_game()
      %{game: game}
    end

    test "passing an affinity card changes a player's score", state do
      game_state = state.game
      turn = game_state.turn
      current_player_id = turn.current
      next_player_id = turn.pass_to |> Enum.at(1)

      affinity_card = CardFixtures.affinity_card_true_anti_cat()
      changes = Playable.pass(affinity_card, game_state, current_player_id, next_player_id)
      new_state = Root.apply_changes(game_state, changes)

      assert new_state.players[current_player_id].affinities.cat == -1
      assert new_state.players[current_player_id].clout == 1

      affinity_card = CardFixtures.affinity_card_true_pro_cat()
      changes = Playable.pass(affinity_card, game_state, current_player_id, next_player_id)
      new_state = Root.apply_changes(game_state, changes)

      assert new_state.players[current_player_id].affinities.cat == 1
      assert new_state.players[current_player_id].clout == 1
    end

    test "keeping an affinity card does not change player's score", state do
      game_state = state.game
      round = game_state.round
      turn = game_state.turn
      current_player_id = turn.current
      next_turn_player_id = Enum.at(round.order, round.current + 1)

      affinity_card = CardFixtures.affinity_card_true_anti_cat()

      changes = Playable.keep(affinity_card, game_state, current_player_id)
      new_state = Root.apply_changes(game_state, changes)
      assert new_state.turn.current == next_turn_player_id
      assert new_state.round.current == 1
    end

    test "discarding an affinity card does not change player's score", state do
      game_state = state.game
      round = game_state.round
      turn = game_state.turn
      current_player_id = turn.current
      next_turn_player_id = Enum.at(round.order, round.current + 1)

      affinity_card = CardFixtures.affinity_card_true_anti_cat()

      changes = Playable.keep(affinity_card, game_state, current_player_id)
      new_state = Root.apply_changes(game_state, changes)

      assert new_state.turn.current == next_turn_player_id
      assert new_state.round.current == 1
    end
  end
end
