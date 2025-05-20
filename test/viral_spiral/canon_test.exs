defmodule ViralSpiral.Canon.DeckEncyclopediaTest do
  use ExUnit.Case
  alias ViralSpiral.Canon
  alias ViralSpiral.Canon.Card.Sparse
  alias ViralSpiral.Canon.DrawTypeRequirements
  alias ViralSpiral.Canon.Encyclopedia
  alias ViralSpiral.Canon.Deck

  @tag timeout: :infinity
  describe "draw_card/2" do
    setup do
      {_, sets, _, _} = Canon.setup()
      %{sets: sets}
    end

    test "drawing and removing card", %{sets: sets} do
      set_key = {:bias, true, :yellow}
      assert Canon.deck_size(sets, set_key) == 30
      member_card_set = Canon.draw_card_from_deck(sets, set_key, 3)
      new_sets = Canon.remove_card_from_deck(sets, set_key, member_card_set)
      assert Canon.deck_size(new_sets, set_key) == 29

      # :rand.seed(:exsss, {1, 87, 90})
      # cards = Deck.load_cards()
      # sets = Deck.create_sets(cards)
      # store = Deck.create_store(cards)

      # requirements = %DrawTypeRequirements{
      #   tgb: 4,
      #   total_tgb: 10,
      #   biases: [:red, :blue],
      #   affinities: [:cat, :sock],
      #   current_player: %{
      #     identity: :blue
      #   }
      # }

      # card_opts = Deck.draw_type(requirements)
      # current_size = Deck.size(sets, card_opts)
      # assert current_size == 30
      # draw_result = Deck.draw_card(sets, card_opts)
      # new_sets = Deck.remove_card(sets, card_opts, draw_result)
      # new_size = Deck.size(new_sets, card_opts)
      # assert new_size = 29
    end
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

    test "turn card to fake", state do
      set = state[:sets]
      store = state[:store]
      article_store = state[:article_store]

      draw_result = Deck.draw_card(set, type: :affinity, veracity: true, tgb: 5, target: :sock)
      card = store[{draw_result.id, true}]
      assert card.headline == "Socks attract rats to your house, beware"

      fake_card = Deck.get_fake_card(store, card.id)
      assert fake_card.headline == "Socks attract rats, (other community)s to your house, beware"
    end

    test "lookup a card's encyclopedia entry", state do
      set = state[:sets]
      store = state[:store]
      article_store = state[:article_store]

      draw_result = Deck.draw_card(set, type: :topical, veracity: true, tgb: 5)
      sparse_card = Sparse.new({draw_result.id, true})

      article =
        Encyclopedia.get_article_by_card(article_store, sparse_card)
        |> IO.inspect()

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
  end
end
