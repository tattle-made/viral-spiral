defmodule ViralSpiral.Canon.Card do
  @moduledoc """
  Load card data from external sources into struct.

  Functions to load cards and handle collection of cards.

  An important data structure with reference to cards is a Store which is a map of a sparse card and its associated card.
  """
  alias ViralSpiral.Canon.Card.Sparse
  alias ViralSpiral.Canon.Card.{Bias, Affinity, Topical, Conflated}

  @type t :: Affinity.t() | Bias.t() | Topical.t() | Conflated.t()

  # a mapping between human readable column headings and their index in the csv file
  @columns %{
    topical: 1,
    topical_fake: 2,
    topical_image: 3,
    anti_red: 4,
    anti_red_image: 5,
    anti_blue: 6,
    anti_blue_image: 7,
    anti_yellow: 8,
    anti_yellow_image: 9,
    pro_cat: 10,
    pro_cat_fake: 11,
    pro_cat_image: 12,
    anti_cat: 13,
    anti_cat_fake: 14,
    anti_cat_image: 15,
    pro_sock: 16,
    pro_sock_fake: 17,
    pro_sock_image: 18,
    anti_sock: 19,
    anti_sock_fake: 20,
    anti_sock_image: 21,
    pro_skub: 22,
    pro_skub_fake: 23,
    pro_skub_image: 24,
    anti_skub: 25,
    anti_skub_fake: 26,
    anti_skub_image: 27,
    pro_high_five: 28,
    pro_high_five_fake: 29,
    pro_high_five_image: 30,
    anti_highfive: 31,
    anti_highfive_fake: 32,
    anti_highfive_image: 33,
    pro_houseboat: 34,
    pro_houseboat_fake: 35,
    pro_houseboat_image: 36,
    anti_houseboat: 37,
    anti_houseboat_fake: 38,
    anti_houseboat_image: 39,
    conflated: 40,
    conflated_image: 41
  }

  @card_master_sheet "all_cards.csv"

  @doc """
  Load card data from file and creates struct
  """
  @spec load() :: list(t())
  def load() do
    parse_file()
    |> Enum.map(&parse_row/1)
    |> Enum.flat_map(& &1)
    |> Enum.filter(&(&1.tgb != -1))
    |> Enum.filter(&(String.length(&1.headline) != 0))
  end

  @doc """
  Create a map of Sparse Card and its associated Card.

  This store is used as the storage for Card data - headline, veracity etc. For most game state operations you truly only need a card's id and veracity (which is stored in a Sparse Card). The store is where you look when you want all remaining fields related to a Sparse Card.
  """
  @spec create_store(list(t())) :: %{Sparse.t() => t()}
  def create_store(cards) do
    Enum.reduce(
      cards,
      %{},
      &Map.put(&2, Sparse.new(&1.id, &1.veracity), &1)
    )
  end

  defp parse_file() do
    File.stream!(Path.join([File.cwd!(), "priv", "canon", @card_master_sheet]))
    |> CSV.decode()
  end

  defp parse_row(row) do
    case row do
      {:ok, row} -> format_row(row)
      {:error, _} -> {:error, "Unable to parse row"}
    end
  end

  defp format_row(row) do
    tgb = Enum.at(row, 0)

    case tgb == -1 do
      true -> {:error, "Unable to format row"}
      false -> split_row_into_cards(row)
    end
  end

  defp split_row_into_cards(row) do
    tgb = String.to_integer(Enum.at(row, 0))

    topical_card_id = card_id(Enum.at(row, @columns.topical))
    anti_red_card_id = card_id(Enum.at(row, @columns.anti_red))
    anti_blue_card_id = card_id(Enum.at(row, @columns.anti_blue))
    anti_yellow_card_id = card_id(Enum.at(row, @columns.anti_yellow))
    pro_cat_card_id = card_id(Enum.at(row, @columns.pro_cat))
    anti_cat_card_id = card_id(Enum.at(row, @columns.anti_cat))
    pro_sock_card_id = card_id(Enum.at(row, @columns.pro_sock))
    anti_sock_card_id = card_id(Enum.at(row, @columns.anti_sock))
    pro_skub_card_id = card_id(Enum.at(row, @columns.pro_skub))
    anti_skub_card_id = card_id(Enum.at(row, @columns.anti_skub))
    pro_high_five_card_id = card_id(Enum.at(row, @columns.pro_high_five))
    anti_high_five_card_id = card_id(Enum.at(row, @columns.anti_highfive))
    pro_houseboat_card_id = card_id(Enum.at(row, @columns.pro_houseboat))
    anti_houseboat_card_id = card_id(Enum.at(row, @columns.anti_houseboat))
    conflated_card_id = card_id(Enum.at(row, @columns.conflated))

    [
      %Topical{
        id: topical_card_id,
        tgb: tgb,
        veracity: true,
        headline: Enum.at(row, @columns.topical),
        image: Enum.at(row, @columns.topical_image)
      },
      %Topical{
        id: topical_card_id,
        tgb: tgb,
        veracity: false,
        headline: Enum.at(row, @columns.topical_fake),
        image: Enum.at(row, @columns.topical_image)
      },
      %Bias{
        id: anti_red_card_id,
        tgb: tgb,
        target: :red,
        veracity: true,
        headline: Enum.at(row, @columns.anti_red),
        image: Enum.at(row, @columns.anti_red_image)
      },
      %Bias{
        id: anti_red_card_id,
        tgb: tgb,
        target: :red,
        veracity: false,
        headline: Enum.at(row, @columns.anti_red),
        image: Enum.at(row, @columns.anti_red_image)
      },
      %Bias{
        id: anti_blue_card_id,
        tgb: tgb,
        target: :blue,
        veracity: true,
        headline: Enum.at(row, @columns.anti_blue),
        image: Enum.at(row, @columns.anti_blue_image)
      },
      %Bias{
        id: anti_blue_card_id,
        tgb: tgb,
        target: :blue,
        veracity: false,
        headline: Enum.at(row, @columns.anti_blue),
        image: Enum.at(row, @columns.anti_blue_image)
      },
      %Bias{
        id: anti_yellow_card_id,
        tgb: tgb,
        target: :yellow,
        veracity: true,
        headline: Enum.at(row, @columns.anti_yellow),
        image: Enum.at(row, @columns.anti_yellow_image)
      },
      %Bias{
        id: anti_yellow_card_id,
        tgb: tgb,
        target: :yellow,
        veracity: false,
        headline: Enum.at(row, @columns.anti_yellow),
        image: Enum.at(row, @columns.anti_yellow_image)
      },
      %Affinity{
        id: pro_cat_card_id,
        tgb: tgb,
        target: :cat,
        veracity: true,
        polarity: :positive,
        headline: Enum.at(row, @columns.pro_cat),
        image: Enum.at(row, @columns.pro_cat_image)
      },
      %Affinity{
        id: pro_cat_card_id,
        tgb: tgb,
        target: :cat,
        veracity: false,
        polarity: :positive,
        headline: Enum.at(row, @columns.pro_cat_fake),
        image: Enum.at(row, @columns.pro_cat_image)
      },
      %Affinity{
        id: anti_cat_card_id,
        tgb: tgb,
        target: :cat,
        veracity: true,
        polarity: :negative,
        headline: Enum.at(row, @columns.anti_cat),
        image: Enum.at(row, @columns.anti_cat_image)
      },
      %Affinity{
        id: anti_cat_card_id,
        tgb: tgb,
        target: :cat,
        veracity: false,
        polarity: :negative,
        headline: Enum.at(row, @columns.anti_cat_fake),
        image: Enum.at(row, @columns.anti_cat_image)
      },
      %Affinity{
        id: pro_sock_card_id,
        tgb: tgb,
        target: :sock,
        veracity: true,
        polarity: :positive,
        headline: Enum.at(row, @columns.pro_sock),
        image: Enum.at(row, @columns.pro_sock_image)
      },
      %Affinity{
        id: pro_sock_card_id,
        tgb: tgb,
        target: :sock,
        veracity: false,
        polarity: :positive,
        headline: Enum.at(row, @columns.pro_sock_fake),
        image: Enum.at(row, @columns.pro_sock_image)
      },
      %Affinity{
        id: anti_sock_card_id,
        tgb: tgb,
        target: :sock,
        veracity: true,
        polarity: :negative,
        headline: Enum.at(row, @columns.anti_sock),
        image: Enum.at(row, @columns.anti_sock_image)
      },
      %Affinity{
        id: anti_sock_card_id,
        tgb: tgb,
        target: :sock,
        veracity: false,
        polarity: :negative,
        headline: Enum.at(row, @columns.anti_sock_fake),
        image: Enum.at(row, @columns.anti_sock_image)
      },
      %Affinity{
        id: pro_skub_card_id,
        tgb: tgb,
        target: :skub,
        veracity: true,
        polarity: :positive,
        headline: Enum.at(row, @columns.pro_skub),
        image: Enum.at(row, @columns.pro_skub_image)
      },
      %Affinity{
        id: pro_skub_card_id,
        tgb: tgb,
        target: :skub,
        veracity: false,
        polarity: :positive,
        headline: Enum.at(row, @columns.pro_skub_fake),
        image: Enum.at(row, @columns.pro_skub_image)
      },
      %Affinity{
        id: anti_skub_card_id,
        tgb: tgb,
        target: :skub,
        veracity: true,
        polarity: :negative,
        headline: Enum.at(row, @columns.anti_skub),
        image: Enum.at(row, @columns.anti_skub_image)
      },
      %Affinity{
        id: anti_skub_card_id,
        tgb: tgb,
        target: :skub,
        veracity: false,
        polarity: :negative,
        headline: Enum.at(row, @columns.anti_skub_fake),
        image: Enum.at(row, @columns.anti_skub_image)
      },
      %Affinity{
        id: pro_high_five_card_id,
        tgb: tgb,
        target: :high_five,
        veracity: true,
        polarity: :positive,
        headline: Enum.at(row, @columns.pro_high_five),
        image: Enum.at(row, @columns.pro_high_five_image)
      },
      %Affinity{
        id: pro_high_five_card_id,
        tgb: tgb,
        target: :highfive,
        veracity: false,
        polarity: :positive,
        headline: Enum.at(row, @columns.pro_high_five_fake),
        image: Enum.at(row, @columns.pro_high_five_image)
      },
      %Affinity{
        id: anti_high_five_card_id,
        tgb: tgb,
        target: :highfive,
        veracity: true,
        polarity: :negative,
        headline: Enum.at(row, @columns.anti_highfive),
        image: Enum.at(row, @columns.anti_highfive_image)
      },
      %Affinity{
        id: anti_high_five_card_id,
        tgb: tgb,
        target: :highfive,
        veracity: false,
        polarity: :negative,
        headline: Enum.at(row, @columns.anti_highfive_fake),
        image: Enum.at(row, @columns.anti_highfive_image)
      },
      %Affinity{
        id: pro_houseboat_card_id,
        tgb: tgb,
        target: :houseboat,
        veracity: true,
        polarity: :positive,
        headline: Enum.at(row, @columns.pro_houseboat),
        image: Enum.at(row, @columns.pro_houseboat_image)
      },
      %Affinity{
        id: pro_houseboat_card_id,
        tgb: tgb,
        target: :houseboat,
        veracity: false,
        polarity: :positive,
        headline: Enum.at(row, @columns.pro_houseboat),
        image: Enum.at(row, @columns.pro_houseboat_image)
      },
      %Affinity{
        id: anti_houseboat_card_id,
        tgb: tgb,
        target: :houseboat,
        veracity: true,
        polarity: :negative,
        headline: Enum.at(row, @columns.anti_houseboat),
        image: Enum.at(row, @columns.anti_houseboat_image)
      },
      %Affinity{
        id: anti_houseboat_card_id,
        tgb: tgb,
        target: :houseboat,
        veracity: false,
        polarity: :negative,
        headline: Enum.at(row, @columns.anti_houseboat),
        image: Enum.at(row, @columns.anti_houseboat_image)
      },
      %Conflated{
        id: conflated_card_id,
        tgb: tgb,
        type: :conflated,
        veracity: false,
        polarity: :neutral,
        headline: Enum.at(row, @columns.conflated),
        image: Enum.at(row, @columns.conflated_image)
      }
    ]
  end

  @doc """
  Generate a hash of the card headline.

  Throughout the csv files, viral spiral writers use the card headline as a link between various sheets and rows.
  """
  def card_id(headline) do
    "card_" <> Integer.to_string(:erlang.phash2(headline))
  end
end
