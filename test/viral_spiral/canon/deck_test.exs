defmodule ViralSpiral.Canon.DeckTest do
  alias ViralSpiral.Canon.Deck.CardSet
  alias ViralSpiral.Canon.Deck
  alias ViralSpiral.Canon.Card
  use ExUnit.Case

  test "create_sets/1" do
    cards = Card.load()
    set = Deck.create_sets(cards)
    assert length(Map.keys(set)) == 11

    set =
      Deck.create_sets(cards,
        affinities: [:cat, :sock, :skub, :houseboat, :highfive],
        biases: [:red, :yellow, :blue]
      )

    assert length(Map.keys(set)) == 19
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
      set_key = CardSet.key(:bias, true, :yellow)
      cardset_member = Deck.draw_card(sets, set_key, 2)
      assert %{id: _id, tgb: _tgb} = cardset_member

      set_key = CardSet.key(:bias, true, :yellow)
      cardset_member = Deck.draw_card(sets, set_key, 8)
      assert %{id: _id, tgb: _tgb} = cardset_member

      set_key = CardSet.key(:affinity, true, :cat)
      cardset_member = Deck.draw_card(sets, set_key, 8)
      assert %{id: _id, tgb: _tgb} = cardset_member

      set_key = CardSet.key(:affinity, false, :cat)
      cardset_member = Deck.draw_card(sets, set_key, 8)
      assert %{id: _id, tgb: _tgb} = cardset_member
    end

    test "remove_card/3", %{sets: sets} do
      true_anti_yellow_set = CardSet.key(:bias, true, :yellow)
      assert Deck.size(sets, true_anti_yellow_set) == 30

      card = CardSet.make_member("card_102551558", 7)
      new_sets = Deck.remove_card(sets, true_anti_yellow_set, card)
      assert Deck.size(new_sets, true_anti_yellow_set) == 29
    end

    test "size/2", %{sets: sets} do
      assert Deck.size(sets, CardSet.key(:conflated, false, nil)) == 6

      assert Deck.size(sets, CardSet.key(:topical, true, nil)) == 30
      assert Deck.size(sets, CardSet.key(:topical, false, nil)) == 30

      assert Deck.size(sets, CardSet.key(:affinity, false, :cat)) == 60
      assert Deck.size(sets, CardSet.key(:affinity, true, :cat)) == 60
      assert Deck.size(sets, CardSet.key(:affinity, false, :sock)) == 60
      assert Deck.size(sets, CardSet.key(:affinity, true, :sock)) == 60
      assert Deck.size(sets, CardSet.key(:affinity, false, :houseboat)) == 60
      assert Deck.size(sets, CardSet.key(:affinity, true, :houseboat)) == 60
      assert Deck.size(sets, CardSet.key(:affinity, false, :highfive)) == 59
      assert Deck.size(sets, CardSet.key(:affinity, true, :highfive)) == 30
      assert Deck.size(sets, CardSet.key(:affinity, false, :skub)) == 60
      assert Deck.size(sets, CardSet.key(:affinity, true, :skub)) == 60

      assert Deck.size(sets, CardSet.key(:bias, false, :red)) == 30
      assert Deck.size(sets, CardSet.key(:bias, true, :red)) == 30
      assert Deck.size(sets, CardSet.key(:bias, false, :yellow)) == 30
      assert Deck.size(sets, CardSet.key(:bias, true, :red)) == 30
      assert Deck.size(sets, CardSet.key(:bias, false, :blue)) == 30
      assert Deck.size(sets, CardSet.key(:bias, true, :blue)) == 30
    end

    test "size!/2", %{sets: sets} do
      set_key = CardSet.key(:affinity, true, :sock)
      assert Deck.size(sets, set_key) > 0
    end
  end
end
