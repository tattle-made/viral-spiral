defmodule ViralSpiral.PlayableTest do
  alias ViralSpiral.Entity.Player
  alias ViralSpiral.Entity.PlayerMap
  alias ViralSpiral.Room.State
  alias ViralSpiral.Playable
  alias ViralSpiral.Affinity
  alias ViralSpiral.Canon.Deck
  use ExUnit.Case

  @tag :skip
  describe "affinity cards" do
    @tag :skip
    setup do
      game = Fixtures.initialized_game()
      %{game: game}
    end

    @tag :skip
    test "passing an affinity card changes a player's score", state do
      game_state = state.game
      turn = game_state.turn
      current_player_id = turn.current
      next_player_id = turn.pass_to |> Enum.at(1)

      affinity_card = CardFixtures.affinity_card_true_anti_cat()
      changes = Playable.pass(affinity_card, game_state, current_player_id, next_player_id)
      new_state = State.apply_changes(game_state, changes)

      assert new_state.players[current_player_id].affinities.cat == -1
      assert new_state.players[current_player_id].clout == 1

      affinity_card = CardFixtures.affinity_card_true_pro_cat()
      changes = Playable.pass(affinity_card, game_state, current_player_id, next_player_id)
      new_state = State.apply_changes(game_state, changes)

      assert new_state.players[current_player_id].affinities.cat == 1
      assert new_state.players[current_player_id].clout == 1
    end

    @tag :skip
    test "keeping an affinity card does not change player's score", state do
      game_state = state.game
      round = game_state.round
      turn = game_state.turn
      current_player_id = turn.current
      next_turn_player_id = Enum.at(round.order, round.current + 1)

      affinity_card = CardFixtures.affinity_card_true_anti_cat()

      changes = Playable.keep(affinity_card, game_state, current_player_id)
      new_state = State.apply_changes(game_state, changes)
      assert new_state.turn.current == next_turn_player_id
      assert new_state.round.current == 1
    end

    @tag :skip
    test "discarding an affinity card does not change player's score", state do
      game_state = state.game
      round = game_state.round
      turn = game_state.turn
      current_player_id = turn.current
      next_turn_player_id = Enum.at(round.order, round.current + 1)

      affinity_card = CardFixtures.affinity_card_true_anti_cat()

      changes = Playable.keep(affinity_card, game_state, current_player_id)
      new_state = State.apply_changes(game_state, changes)

      assert new_state.turn.current == next_turn_player_id
      assert new_state.round.current == 1
    end
  end

  @tag :skip
  describe "bias cards" do
    setup do
      :rand.seed(:exsss, {1, 2, 5})
      game = Fixtures.initialized_game()
      %{game: game}
    end

    @tag :skip
    test "pass card", state do
      game_state = state.game
      players = game_state.players
      round = game_state.round
      turn = game_state.turn
      card = CardFixtures.bias_card(:blue, true)
      current_player_id = turn.current
      to_player_id = Enum.at(turn.pass_to, 1)

      changes = Playable.pass(card, game_state, current_player_id, to_player_id)
      new_state = State.apply_changes(game_state, changes)

      current_player = new_state.players[current_player_id]
      # current player's clout should increase by 1
      assert current_player.clout == 1
      # current player's bias against blue community should increase by 1
      assert current_player.biases.blue == 1

      blue_players =
        PlayerMap.others(new_state.players, current_player_id)
        |> PlayerMap.of_identity(:blue)

      # players with blue identity should lose a clout
      Enum.map(blue_players, fn {_id, blue_player} ->
        assert match?(%Player{clout: -1}, blue_player)
      end)

      # turn should move to to_player_id
      assert new_state.turn.current == to_player_id
    end

    @tag :skip
    test "keep card", state do
      game_state = state.game
      card = CardFixtures.bias_card(:blue, true)
      turn = game_state.turn
      current_player_id = turn.current

      changes = Playable.keep(card, game_state, current_player_id)
      new_state = State.apply_changes(game_state, changes)

      # card is added to the player's hand
      assert new_state.players[current_player_id].hand == [card.id]

      # next round has begun
      assert new_state.round.current == 1
      # next turn has begun
      assert new_state.turn.pass_to |> length() == 3
    end

    test "discard card", state do
    end
  end
end
