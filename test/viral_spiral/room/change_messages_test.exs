defmodule ViralSpiral.Room.ChangeMessagesTest do
  alias ViralSpiral.Entity.ChangeMessages
  alias ViralSpiral.Room.Actions
  alias ViralSpiral.Canon.Card.Sparse
  alias ViralSpiral.Canon.Deck
  alias ViralSpiral.Canon.Deck.CardSet
  alias ViralSpiral.Entity.Changes
  alias ViralSpiral.Room.StateTransformation
  use ExUnit.Case

  # In addition to the card type, message would vary depending on the following parameters :
  # sender's identity, card target(affinity, bias or both), other player's identity.
  # The various test cases in each suite try to cover these possibilities.
  describe "pass bias card" do
    setup do
      :rand.seed(:exsss, {123, 135, 254})
      {state, players} = StateFixtures.new_game_with_four_players()
      %{state: state, players: players}
    end

    test "sender identity - :red, card target - :blue, others - [:red, :yellow, :blue] ", %{
      state: state,
      players: players
    } do
      %{adhiraj: adhiraj, aman: aman, farah: farah, krys: krys} = players

      state =
        state
        |> StateTransformation.update_round(%{order: [adhiraj, aman, krys, farah]})
        |> StateTransformation.update_turn(%{current: adhiraj, pass_to: [aman, krys, farah]})
        |> StateTransformation.update_player(adhiraj, %{identity: :red})
        |> StateTransformation.update_player(aman, %{identity: :blue})
        |> StateTransformation.update_player(farah, %{identity: :red})
        |> StateTransformation.update_player(krys, %{identity: :yellow})

      card_sets = state.deck.available_cards
      set_key = CardSet.key(:bias, true, :blue)
      cardset_member = Deck.draw_card(card_sets, set_key, 4)
      sparse_card = Sparse.new(cardset_member.id, true)

      state = state |> StateTransformation.update_player(adhiraj, %{active_cards: [sparse_card]})

      pass_card_attrs = %{
        from_id: adhiraj,
        to_id: aman,
        card: %{
          id: sparse_card.id,
          veracity: sparse_card.veracity
        }
      }

      changes = Changes.change(state, Actions.pass_card(pass_card_attrs))
      change_reasons = ChangeMessages.message_reasons(changes)

      assert change_reasons == [
               :clout_current_turn_player_passed_card,
               :bias_current_turn_player_shared_bias_card,
               :clout_current_turn_player_shared_bias_card_targetting_other_player,
               :chaos_current_turn_player_shared_bias_card
             ]
    end

    # when multiple players are targetted by a bias card
    test "sender identity - :yellow, card target - :blue, others - [:blue, :blue, :red] ", %{
      state: state,
      players: players
    } do
      %{adhiraj: adhiraj, aman: aman, farah: farah, krys: krys} = players

      state =
        state
        |> StateTransformation.update_round(%{order: [adhiraj, aman, krys, farah]})
        |> StateTransformation.update_turn(%{current: adhiraj, pass_to: [aman, krys, farah]})
        |> StateTransformation.update_player(adhiraj, %{identity: :yellow})
        |> StateTransformation.update_player(aman, %{identity: :blue})
        |> StateTransformation.update_player(farah, %{identity: :blue})
        |> StateTransformation.update_player(krys, %{identity: :red})

      card_sets = state.deck.available_cards
      set_key = CardSet.key(:bias, true, :blue)
      cardset_member = Deck.draw_card(card_sets, set_key, 4)
      sparse_card = Sparse.new(cardset_member.id, true)

      state = state |> StateTransformation.update_player(adhiraj, %{active_cards: [sparse_card]})

      pass_card_attrs = %{
        from_id: adhiraj,
        to_id: aman,
        card: %{
          id: sparse_card.id,
          veracity: sparse_card.veracity
        }
      }

      changes = Changes.change(state, Actions.pass_card(pass_card_attrs))
      change_reasons = ChangeMessages.message_reasons(changes)

      assert change_reasons == [
               :clout_current_turn_player_passed_card,
               :bias_current_turn_player_shared_bias_card,
               :clout_current_turn_player_shared_bias_card_targetting_other_player,
               :clout_current_turn_player_shared_bias_card_targetting_other_player,
               :chaos_current_turn_player_shared_bias_card
             ]
    end

    # when card is shared by a player other than whose round it is
    test "sender identity - :yellow, card target - :blue, others - [:red, :yellow, :blue] ", %{
      state: state,
      players: players
    } do
      %{adhiraj: adhiraj, aman: aman, farah: farah, krys: krys} = players

      state =
        state
        |> StateTransformation.update_round(%{order: [adhiraj, aman, krys, farah]})
        # to simulate adhiraj has shared their card with aman in this round
        |> StateTransformation.update_turn(%{
          current: aman,
          pass_to: [krys, farah],
          path: [adhiraj]
        })
        |> StateTransformation.update_player(adhiraj, %{identity: :blue})
        |> StateTransformation.update_player(aman, %{identity: :yellow})
        |> StateTransformation.update_player(farah, %{identity: :red})
        |> StateTransformation.update_player(krys, %{identity: :yellow})

      card_sets = state.deck.available_cards
      set_key = CardSet.key(:bias, true, :blue)
      cardset_member = Deck.draw_card(card_sets, set_key, 4)
      sparse_card = Sparse.new(cardset_member.id, true)

      state = state |> StateTransformation.update_player(adhiraj, %{active_cards: [sparse_card]})

      pass_card_attrs = %{
        from_id: adhiraj,
        to_id: aman,
        card: %{
          id: sparse_card.id,
          veracity: sparse_card.veracity
        }
      }

      changes = Changes.change(state, Actions.pass_card(pass_card_attrs))
      change_reasons = ChangeMessages.message_reasons(changes)

      assert change_reasons == [
               :clout_current_turn_player_passed_card,
               :bias_current_turn_player_shared_bias_card,
               :clout_current_turn_player_shared_bias_card_targetting_other_player,
               :chaos_current_turn_player_shared_bias_card
             ]
    end
  end
end
