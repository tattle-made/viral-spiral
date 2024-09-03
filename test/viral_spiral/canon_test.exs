defmodule ViralSpiral.CanonTest do
  alias ViralSpiral.Canon.Encyclopedia
  alias ViralSpiral.Canon.Deck

  describe "deck integrity" do
  end

  describe "deck functions" do
    setup do
      cards = Deck.load_cards()
      store = Deck.create_store(cards)
      sets = Deck.create_sets(cards)

      articles = Encyclopedia.load_articles()
      article_store = Encyclopedia.create_store(articles)

      cards = Deck.link(cards, article_store)

      %{cards: cards, articles: articles}
    end

    test "turn card to fake" do
    end

    test "lookup a card's encyclopedia entry" do
    end

    test "card text replacement for dynamic cards" do
    end
  end
end
