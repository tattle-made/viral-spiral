defmodule ViralSpiral.Canon.DynamicCardTest do
  use ExUnit.Case
  alias ViralSpiral.Canon.Card.Affinity
  alias ViralSpiral.Canon.Card.Topical
  alias ViralSpiral.Canon.DynamicCard

  test "find placeholder text for (other community)" do
    headline = "(other community) club shover crime spree continues - another rave in disarray"
    matches = DynamicCard.find_placeholders(headline)
    assert Enum.at(matches, 0) == :other_community
  end

  test "find placeholder text for (dominant community)" do
    headline = "(dominant community) club shover crime spree continues - another rave in disarray"
    matches = DynamicCard.find_placeholders(headline)
    assert Enum.at(matches, 0) == :dominant_community
  end

  test "find placeholder text for (oppressed community)" do
    headline =
      "City announces discriminatory rating system to filter 'productive' members of (oppressed community) community from others"

    matches = DynamicCard.find_placeholders(headline)
    assert Enum.at(matches, 0) == :oppressed_community
  end

  test "find placeholder text for (popuar affinity)" do
    headline = "People who like (popular affinity) are good"

    matches = DynamicCard.find_placeholders(headline)
    assert Enum.at(matches, 0) == :popular_affinity
  end

  test "find placeholder text for (unpopuar affinity)" do
    headline = "People who like (unpopular affinity) are good"

    matches = DynamicCard.find_placeholders(headline)
    assert Enum.at(matches, 0) == :unpopular_affinity
  end

  test "replace multiple placeholder text" do
    headline = "People who like (unpopular affinity) are usually (dominant community)"

    matches = DynamicCard.find_placeholders(headline)

    replacements = %{
      unpopular_affinity: :skub,
      dominant_community: :red
    }

    new_headline = DynamicCard.replace_text(headline, matches, replacements)
    assert new_headline == "People who like Skub are usually Red"
  end

  test "patch card" do
    card = %Topical{
      id: "card_80978491",
      tgb: 1,
      type: :topical,
      veracity: false,
      polarity: :neutral,
      headline:
        "Unexpected heat wave a huge blow to farmers, pedestrians, birds delighting (other community) puppetmasters",
      image: "F_HEATWAVE copy.png",
      article_id: nil,
      bias: nil
    }

    identity_stats = %{
      dominant_community: :blue,
      oppressed_community: :blue,
      other_community: :yellow,
      player_community: :blue,
      popular_affinity: :houseboat,
      unpopular_affinity: :houseboat
    }

    new_card = DynamicCard.patch(card, identity_stats)
    assert new_card.bias.target == :yellow

    card = %Affinity{
      id: "card_80978491",
      tgb: 1,
      type: :affinity,
      target: :cat,
      veracity: false,
      polarity: :negative,
      headline: "City motto changed to \"Death to all cats and (other community)s\"",
      image: "C_MOTTO COPY.png",
      article_id: nil,
      bias: nil
    }

    identity_stats = %{
      dominant_community: :blue,
      oppressed_community: :blue,
      other_community: :yellow,
      player_community: :blue,
      popular_affinity: :houseboat,
      unpopular_affinity: :houseboat
    }

    new_card = DynamicCard.patch(card, identity_stats)
    assert new_card.bias.target == :yellow
  end
end
