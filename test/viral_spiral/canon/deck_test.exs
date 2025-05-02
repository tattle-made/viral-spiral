defmodule ViralSpiral.Canon.DeckTest do
  alias ViralSpiral.Canon.Card.Sparse
  alias ViralSpiral.Canon.Deck.CardSet
  alias ViralSpiral.Canon.Deck
  alias ViralSpiral.Canon.Card
  use ExUnit.Case

  # RESUME : Deck.remove_card
  # draw_type_opts_to_tuple might not be needed either.

  test "create_sets/1" do
    cards = Card.load()
    set = Deck.create_sets(cards)
    # assert
  end

  describe "set" do
    setup do
      cards = Card.load()

      sets =
        Deck.create_sets(cards,
          affinities: [:cat, :sock, :skub, :houseboat, :highfive],
          biases: [:red, :yellow, :blue]
        )

      %{sets: sets}
    end

    test "draw_card/2", %{sets: sets} do
      set_key = CardSet.key(:bias, :yellow, true)
      cardset_member = Deck.draw_card(sets, set_key, 2)
      assert %Sparse{} = cardset_member

      set_key = CardSet.key(:bias, :yellow, false)
      cardset_member = Deck.draw_card(sets, set_key, 8)
      assert %Sparse{} = cardset_member

      set_key = CardSet.key(:affinity, :cat, true)
      cardset_member = Deck.draw_card(sets, set_key, 8)
      assert %Sparse{} = cardset_member

      set_key = CardSet.key(:affinity, :cat, false)
      cardset_member = Deck.draw_card(sets, set_key, 8)
      assert %Sparse{} = cardset_member
    end

    test "remove_card/3", %{sets: sets} do
      true_anti_yellow_set = CardSet.key(:bias, :yellow, true)
      assert Deck.size(new_sets, true_anti_yellow_set) == 30

      card = CardSet.member("card_102551558", 7)
      new_sets = Deck.remove_card(sets, true_anti_yellow_set, card)
      Deck.size(new_sets, true_anti_yellow_set)
    end

    test "size/2", %{sets: sets} do
      assert Deck.size(sets, CardSet.key(:conflated, false)) == 6

      assert Deck.size(sets, CardSet.key(:topical, true)) == 30
      assert Deck.size(sets, CardSet.key(:topical, false)) == 30

      assert Deck.size(sets, CardSet.key(:affinity, :cat, false)) == 60
      assert Deck.size(sets, CardSet.key(:affinity, :cat, true)) == 60
      assert Deck.size(sets, CardSet.key(:affinity, :sock, false)) == 60
      assert Deck.size(sets, CardSet.key(:affinity, :sock, true)) == 60
      assert Deck.size(sets, CardSet.key(:affinity, :houseboat, false)) == 60
      assert Deck.size(sets, CardSet.key(:affinity, :houseboat, true)) == 60
      assert Deck.size(sets, CardSet.key(:affinity, :highfive, false)) == 59
      assert Deck.size(sets, CardSet.key(:affinity, :highfive, true)) == 30
      assert Deck.size(sets, CardSet.key(:affinity, :skub, false)) == 60
      assert Deck.size(sets, CardSet.key(:affinity, :skub, true)) == 60

      assert Deck.size(sets, CardSet.key(:bias, :red, false)) == 30
      assert Deck.size(sets, CardSet.key(:bias, :red, true)) == 30
      assert Deck.size(sets, CardSet.key(:bias, :yellow, false)) == 30
      assert Deck.size(sets, CardSet.key(:bias, :red, true)) == 30
      assert Deck.size(sets, CardSet.key(:bias, :blue, false)) == 30
      assert Deck.size(sets, CardSet.key(:bias, :blue, true)) == 30
    end

    test "size!/2", %{sets: sets} do
      set_key = Set.key(:affinity, :sock, true)
      assert Deck.size(sets, set_key) > 0

      assert_raise FunctionClauseError, fn ->
        Deck.size(sets, Set.key(:affinity, :random, true))
      end

      assert_raise FunctionClauseError, fn ->
        Deck.size(sets, Set.key(1, :random, true))
      end
    end
  end
end
