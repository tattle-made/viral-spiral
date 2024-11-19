defmodule ViralSpiral.Entity.DeckTest do
  alias ViralSpiral.Canon.Deck, as: CanonDeck
  alias ViralSpiral.Room.ChangeOptions
  alias ViralSpiral.Entity.Change
  alias ViralSpiral.Entity.Deck
  use ExUnit.Case

  describe "changes" do
    setup do
      deck = Deck.new()

      %{deck: deck}
    end

    test "remove card", %{deck: deck} do
      draw_type = [type: :affinity, veracity: true, tgb: 2, target: :cat]
      draw_result = CanonDeck.draw_card(deck.available_cards, draw_type)

      new_deck = Change.apply_change(deck, nil, ChangeOptions.remove_card(draw_type, draw_result))
      assert MapSet.size(new_deck.available_cards[{:affinity, true, :cat}]) == 59
    end
  end
end
