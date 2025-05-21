defmodule ViralSpiral.Canon.DeckEncyclopediaTest do
  use ExUnit.Case
  alias ViralSpiral.Canon
  alias ViralSpiral.Canon.Card.Sparse
  alias ViralSpiral.Canon.DrawTypeRequirements

  describe "canon" do
    setup do
      :rand.seed(:exsss, {12356, 123_534, 345_345})

      canon = Canon.setup()
      %{canon: canon}
    end

    test "drawing and removing card", %{canon: canon} do
      {_, sets, _, _} = canon
      set_key = {:bias, true, :yellow}
      assert Canon.deck_size(sets, set_key) == 30
      member_card_set = Canon.draw_card_from_deck(sets, set_key, 3)
      new_sets = Canon.remove_card_from_deck(sets, set_key, member_card_set)
      assert Canon.deck_size(new_sets, set_key) == 29
    end

    test "get source", %{canon: canon} do
      {card_store, card_sets, _, article_store} = canon

      set_key = {:topical, true}
      member_card_set = Canon.draw_card_from_deck(card_sets, set_key, 5)

      article = Canon.get_article(article_store, Sparse.new(member_card_set.id, true))

      assert article.headline == "City Lit Fest introduces new segment: books for party animals"
      assert article.veracity == true
    end

    test "get fake card", %{canon: canon} do
      {card_store, card_sets, _, _} = canon

      set_key = {:topical, true}
      member_card_set = Canon.draw_card_from_deck(card_sets, set_key, 6)
      card = card_store[Sparse.new(member_card_set.id, true)]

      assert card.headline ==
               "City Lit Fest descends into chaos as PartyHeads set their own books on fire"

      fake_card = Canon.get_fake_card_from_card_store(card_store, card.id)
      assert fake_card.veracity == false

      assert fake_card.headline ==
               "City Lit Fest descends into chaos as (other community) nutjobs set books on fire"
    end
  end
end
