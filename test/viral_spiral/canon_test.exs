defmodule ViralSpiral.CanonTest do
  use ExUnit.Case
  alias ViralSpiral.Canon.Encyclopedia
  alias ViralSpiral.Canon.Deck

  describe "card data integrity" do
  end

  describe "deck functions" do
    setup do
      :rand.seed(:exsss, {12356, 123_534, 345_345})
      cards = Deck.load_cards()
      articles = Encyclopedia.load_articles()
      article_store = Encyclopedia.create_store(articles)
      cards = Deck.link(cards, article_store)

      store = Deck.create_store(cards)
      sets = Deck.create_sets(cards)

      %{cards: cards, store: store, sets: sets, articles: articles, article_store: article_store}
    end

    test "drawing a card should reduce available cards by 1" do
    end

    test "turn card to fake", state do
      set = state[:sets]
      store = state[:store]
      article_store = state[:article_store]

      card_id = Deck.draw_card(set, type: :affinity, veracity: true, tgb: 5, target: :sock)
      card = store[{card_id, true}]
      assert card.headline == "Socks attract rats to your house, beware"

      fake_card = Deck.get_fake_card(store, card.id)
      assert fake_card.headline == "Socks attract rats, (other community)s to your house, beware"
    end

    test "lookup a card's encyclopedia entry", state do
      set = state[:sets]
      store = state[:store]
      article_store = state[:article_store]

      card_id = Deck.draw_card(set, type: :topical, veracity: true, tgb: 5)
      card = store[{card_id, true}]
      assert card.id == "card_27424926"
      assert card.veracity == true

      article = Encyclopedia.get_article_by_card(article_store, card)

      assert article.headline ==
               "Global pocket shortage finally hits City, driving up prices of dresses with pockets"

      assert article.veracity == true
    end
  end

  describe "dynamic text on card" do
    setup do
      :rand.seed(:exsss, {12356, 123_534, 345_345})

      game = Fixtures.initialized_game()

      cards = Deck.load_cards()
      store = Deck.create_store(cards)
      sets = Deck.create_sets(cards)

      %{cards: cards, store: store, sets: sets, game: game}
    end

    test "card text replacement for card with dominant community", state do
      # todo game needs helper functions for
      # oppressed community, dominant community etc
      game_state = state[:game]
      player_scores = game_state.player_scores
      card_store = state[:store]

      headline = "(dominant capes) hold march through City, police joins in"
      card_id = Deck.card_id(headline)
      card = card_store[{card_id, true}]

      card = Deck.substitute_text(game_state, card) |> IO.inspect()
      assert String.contains?(card.headline, "(dominant capes)") == false

      # players = Fixtures.player_list() |> IO.inspect()
      # player_score_list = Fixtures.player_score_list(players)
    end
  end
end
