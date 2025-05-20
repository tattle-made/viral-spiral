defmodule DeckFixtures do
  alias ViralSpiral.Canon.Card.{Topical, Affinity, Bias, Conflated, Sparse}

  def cards() do
    [
      %Topical{
        id: "card_topical_1",
        tgb: 0,
        veracity: true,
        headline: "topical headline 1",
        image: "topical_image_1.png"
      },
      %Topical{
        id: "card_topical_2",
        tgb: 0,
        veracity: false,
        headline: "topical headline 2",
        image: "topical_image_2.png"
      },
      %Bias{
        id: "card_bias_1"
      }
    ]
  end
end
