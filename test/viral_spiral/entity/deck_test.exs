defmodule ViralSpiral.Entity.DeckTest do
  alias ViralSpiral.Room.ChangeDescriptions
  alias ViralSpiral.Entity.Change
  alias ViralSpiral.Entity.Deck
  use ExUnit.Case

  describe "changes" do
    setup do
      deck = Deck.new()

      %{deck: deck}
    end

    @tag timeout: :infinity
    test "remove card", %{deck: deck} do
      IO.inspect("hi")
      # draw_type = [type: :affinity, veracity: true, tgb: 2, target: :cat]
      # draw_result = CanonDeck.draw_card(deck.available_cards, draw_type)

      # new_deck =
      #   Change.apply_change(deck, ChangeDescriptions.remove_card(draw_type, draw_result))

      # assert CanonDeck.size(new_deck.available_cards, draw_type) == 59
    end
  end
end
