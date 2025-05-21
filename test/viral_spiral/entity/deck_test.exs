defmodule ViralSpiral.Entity.DeckTest do
  alias ViralSpiral.Entity.Deck.Changes.RemoveCard
  alias ViralSpiral.Canon
  alias ViralSpiral.Room.ChangeDescriptions
  alias ViralSpiral.Entity.Change
  alias ViralSpiral.Entity.Deck
  use ExUnit.Case

  describe "changes" do
    setup do
      deck = Deck.new()
      %{deck: deck}
    end

    test "remove card", %{deck: deck} do
      card_sets = deck.available_cards

      set_key = {:bias, true, :yellow}
      assert Canon.deck_size(card_sets, set_key) == 30
      card = Canon.draw_card_from_deck(card_sets, set_key, 3)

      new_deck =
        Change.change(deck, %RemoveCard{card_sets: card_sets, card_type: set_key, card: card})

      assert Canon.deck_size(new_deck.available_cards, set_key) == 29
    end
  end
end
