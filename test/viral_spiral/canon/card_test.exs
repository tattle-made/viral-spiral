defmodule ViralSpiral.Canon.CardTest do
  alias ViralSpiral.Canon.Card.{Topical, Bias, Affinity, Conflated, Sparse}
  alias ViralSpiral.Canon.Card
  use ExUnit.Case

  test "load/0" do
    cards = Card.load()
    assert length(cards) == 845

    # assert card types
    [topical_true, topical_false] = Enum.slice(cards, 0..1)
    assert %Topical{} = topical_true
    assert %Conflated{} = topical_false

    [bias_red_true, bias_red_false] = Enum.slice(cards, 2..3)
    assert %Bias{} = bias_red_true
    assert %Bias{} = bias_red_false

    [bias_blue_true, bias_blue_false] = Enum.slice(cards, 4..5)
    assert %Bias{} = bias_blue_true
    assert %Bias{} = bias_blue_false

    [bias_yellow_true, bias_yellow_false] = Enum.slice(cards, 6..7)
    assert %Bias{} = bias_yellow_true
    assert %Bias{} = bias_yellow_false

    [pro_cat_true, pro_cat_false] = Enum.slice(cards, 8..9)
    assert %Affinity{} = pro_cat_true
    assert %Conflated{} = pro_cat_false

    [anti_cat_true, anti_cat_false] = Enum.slice(cards, 10..11)
    assert %Affinity{} = anti_cat_true
    assert %Conflated{} = anti_cat_false
  end

  test "create_store/1" do
    cards = Card.load()
    card_store = Card.create_store(cards)

    assert length(Map.keys(card_store)) == 845

    card = card_store[Sparse.new("card_36453698", true)]
    assert %Affinity{} = card
    assert card.headline == "Sock-maker bags Award for Outstanding Philanthropy"
    assert card.polarity == :positive
  end

  test "card_id/1" do
    id_a = Card.card_id("example headline goes here")
    assert id_a == "card_15224363"

    id_b = Card.card_id("another example headline goes here")
    assert id_b == "card_121882267"
  end
end
