defmodule ViralSpiral.Canon.Deck do
  @moduledoc """
  Loads data from .csv files.

  Viral Spiral writers use Google Sheet to organize the text content for the game. The current sheet is [here](https://docs.google.com/spreadsheets/d/1070fP6LOjCTfLl7SoQuGA4FxNJ3XLWbzZj35eABizgk/edit?usp=sharing)
  Each sheet within the sheet is exported as .csv files and stored in the `priv/canon/` directory. This module encodes the conventions used by the writers in the file to generate structured data structures from the csv file. It also converts the structured data into datastructures optimized for the game's requirements.

  <div class="mermaid">
  stateDiagram-v2
    file: CSV File
    file --> Cards
    Cards --> Store : Common
    Cards --> Sets : Room Specific
  </div>

  Store is a Map of all cards. Keys in this Map are unique ids for every card and the values are cards (`ViralSpiral.Canon.Card.Affinity`, `ViralSpiral.Canon.Card.Bias`, `ViralSpiral.Canon.Card.Topical` and `ViralSpiral.Canon.Card.Conflated`).

  Sets is a Map of cards. Keys of this Map are a tuple of the form `{type, veracity, target}`. Value of this Map is `MapSet` of cards. For instance, for a room where the active affinities are :cat and :sock; and the active communities are :red and :yellow; the Sets would have the following keys :
  [
    {:conflated, false},
    {:topical, false},
    {:topical, true},
    {:affinity, false, :cat},
    {:affinity, false, :sock},
    {:affinity, true, :cat},
    {:affinity, true, :sock},
    {:bias, false, :red},
    {:bias, false, :yellow},
    {:bias, true, :red},
    {:bias, true, :yellow}
  ]


  ## Example Usage
  ```elixir
  cards = Deck.load_cards()
  store = Deck.create_store(cards)
  sets = Deck.create_sets(cards)

  card_id = Deck.draw_card(deck, type: :affinity, veracity: true, tgb: 0, target: :skub)
  card_id = Deck.draw_card(deck, type: :bias, veracity: true, tgb: 0, target: :red)
  card_id = Deck.draw_card(deck, type: :topical, veracity: true, tgb: 0)

  card_data = store[card]
  ```
  Read documentation of `draw_card` to see more examples of the responses.

  """
  alias ViralSpiral.Canon.Card.Affinity
  alias ViralSpiral.Canon.Card.Bias
  alias ViralSpiral.Canon.Card.Topical

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
  @set_opts_default [affinities: [:cat, :sock], biases: [:red, :yellow]]
  @card_master_sheet "all_cards.csv"

  def load_cards() do
    parse_file()
    |> Enum.map(&parse_row/1)
    |> Enum.flat_map(& &1)
    |> Enum.filter(&(&1.tgb != -1))
    |> Enum.filter(&(String.length(&1.headline) != 0))
  end

  @doc """
  Creates a Map of MapSet of cards partitioned by its type and veracity.

  For instance to access affinity cards of veracity true, access deck[{:affinity, true}]
  iex> {store, set} = Deck.create_partitioned_deck
  store[{:bias, false}] |> Mapset.size
  """
  def create_store(cards) do
    Enum.reduce(
      cards,
      %{},
      &Map.put(&2, &1.id, &1)
    )
  end

  def create_sets(cards, opts \\ @set_opts_default) do
    affinities = opts[:affinities]
    biases = opts[:biases]

    common_cards = cards |> Enum.filter(&(&1.type in [:topical, :conflated]))
    affinity_cards = cards |> Enum.filter(&(&1.type == :affinity and &1.target in affinities))
    bias_cards = cards |> Enum.filter(&(&1.type == :bias and &1.target in biases))

    cards = common_cards ++ affinity_cards ++ bias_cards

    grouped_card =
      cards
      |> Enum.group_by(&key(&1))

    Enum.reduce(
      Map.keys(grouped_card),
      %{},
      &Map.put(&2, &1, Enum.map(grouped_card[&1], fn card -> id_tgb(card) end))
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

    [
      %Topical{
        id: UXID.generate!(prefix: "card", size: :small),
        tgb: tgb,
        veracity: true,
        headline: Enum.at(row, @columns.topical),
        image: Enum.at(row, @columns.topical_image)
      },
      %Topical{
        id: UXID.generate!(prefix: "card", size: :small),
        tgb: tgb,
        veracity: false,
        headline: Enum.at(row, @columns.topical_fake),
        image: Enum.at(row, @columns.topical_image)
      },
      %Bias{
        id: UXID.generate!(prefix: "card", size: :small),
        tgb: tgb,
        target: :red,
        veracity: true,
        headline: Enum.at(row, @columns.anti_red),
        image: Enum.at(row, @columns.anti_red_image)
      },
      %Bias{
        id: UXID.generate!(prefix: "card", size: :small),
        tgb: tgb,
        target: :red,
        veracity: false,
        headline: Enum.at(row, @columns.anti_red),
        image: Enum.at(row, @columns.anti_red_image)
      },
      %Bias{
        id: UXID.generate!(prefix: "card", size: :small),
        tgb: tgb,
        target: :blue,
        veracity: true,
        headline: Enum.at(row, @columns.anti_blue),
        image: Enum.at(row, @columns.anti_blue_image)
      },
      %Bias{
        id: UXID.generate!(prefix: "card", size: :small),
        tgb: tgb,
        target: :blue,
        veracity: false,
        headline: Enum.at(row, @columns.anti_blue),
        image: Enum.at(row, @columns.anti_blue_image)
      },
      %Bias{
        id: UXID.generate!(prefix: "card", size: :small),
        tgb: tgb,
        target: :yellow,
        veracity: true,
        headline: Enum.at(row, @columns.anti_yellow),
        image: Enum.at(row, @columns.anti_yellow_image)
      },
      %Bias{
        id: UXID.generate!(prefix: "card", size: :small),
        tgb: tgb,
        target: :yellow,
        veracity: false,
        headline: Enum.at(row, @columns.anti_yellow),
        image: Enum.at(row, @columns.anti_yellow_image)
      },
      %Affinity{
        id: UXID.generate!(prefix: "card", size: :small),
        tgb: tgb,
        target: :cat,
        veracity: true,
        polarity: :positive,
        headline: Enum.at(row, @columns.pro_cat),
        image: Enum.at(row, @columns.pro_cat_image)
      },
      %Affinity{
        id: UXID.generate!(prefix: "card", size: :small),
        tgb: tgb,
        target: :cat,
        veracity: false,
        polarity: :positive,
        headline: Enum.at(row, @columns.pro_cat_fake),
        image: Enum.at(row, @columns.pro_cat_image)
      },
      %Affinity{
        id: UXID.generate!(prefix: "card", size: :small),
        tgb: tgb,
        target: :cat,
        veracity: true,
        polarity: :negative,
        headline: Enum.at(row, @columns.anti_cat),
        image: Enum.at(row, @columns.anti_cat_image)
      },
      %Affinity{
        id: UXID.generate!(prefix: "card", size: :small),
        tgb: tgb,
        target: :cat,
        veracity: false,
        polarity: :negative,
        headline: Enum.at(row, @columns.anti_cat_fake),
        image: Enum.at(row, @columns.anti_cat_image)
      },
      %Affinity{
        id: UXID.generate!(prefix: "card", size: :small),
        tgb: tgb,
        target: :sock,
        veracity: true,
        polarity: :positive,
        headline: Enum.at(row, @columns.pro_sock),
        image: Enum.at(row, @columns.pro_sock_image)
      },
      %Affinity{
        id: UXID.generate!(prefix: "card", size: :small),
        tgb: tgb,
        target: :sock,
        veracity: false,
        polarity: :positive,
        headline: Enum.at(row, @columns.pro_sock),
        image: Enum.at(row, @columns.pro_sock_image)
      },
      %Affinity{
        id: UXID.generate!(prefix: "card", size: :small),
        tgb: tgb,
        target: :sock,
        veracity: true,
        polarity: :negative,
        headline: Enum.at(row, @columns.anti_sock),
        image: Enum.at(row, @columns.anti_sock_image)
      },
      %Affinity{
        id: UXID.generate!(prefix: "card", size: :small),
        tgb: tgb,
        target: :sock,
        veracity: false,
        polarity: :negative,
        headline: Enum.at(row, @columns.anti_sock),
        image: Enum.at(row, @columns.anti_sock_image)
      },
      %Affinity{
        id: UXID.generate!(prefix: "card", size: :small),
        tgb: tgb,
        target: :skub,
        veracity: true,
        polarity: :positive,
        headline: Enum.at(row, @columns.pro_skub),
        image: Enum.at(row, @columns.pro_skub_image)
      },
      %Affinity{
        id: UXID.generate!(prefix: "card", size: :small),
        tgb: tgb,
        target: :skub,
        veracity: false,
        polarity: :positive,
        headline: Enum.at(row, @columns.pro_skub),
        image: Enum.at(row, @columns.pro_skub_image)
      },
      %Affinity{
        id: UXID.generate!(prefix: "card", size: :small),
        tgb: tgb,
        target: :skub,
        veracity: true,
        polarity: :negative,
        headline: Enum.at(row, @columns.anti_skub),
        image: Enum.at(row, @columns.anti_skub_image)
      },
      %Affinity{
        id: UXID.generate!(prefix: "card", size: :small),
        tgb: tgb,
        target: :skub,
        veracity: false,
        polarity: :negative,
        headline: Enum.at(row, @columns.anti_skub),
        image: Enum.at(row, @columns.anti_skub_image)
      },
      %Affinity{
        id: UXID.generate!(prefix: "card", size: :small),
        tgb: tgb,
        target: :high_five,
        veracity: true,
        polarity: :positive,
        headline: Enum.at(row, @columns.pro_high_five),
        image: Enum.at(row, @columns.pro_high_five_image)
      },
      %Affinity{
        id: UXID.generate!(prefix: "card", size: :small),
        tgb: tgb,
        target: :highfive,
        veracity: false,
        polarity: :positive,
        headline: Enum.at(row, @columns.pro_high_five),
        image: Enum.at(row, @columns.pro_high_five_image)
      },
      %Affinity{
        id: UXID.generate!(prefix: "card", size: :small),
        tgb: tgb,
        target: :highfive,
        veracity: true,
        polarity: :negative,
        headline: Enum.at(row, @columns.anti_highfive),
        image: Enum.at(row, @columns.anti_highfive_image)
      },
      %Affinity{
        id: UXID.generate!(prefix: "card", size: :small),
        tgb: tgb,
        target: :highfive,
        veracity: false,
        polarity: :negative,
        headline: Enum.at(row, @columns.anti_highfive),
        image: Enum.at(row, @columns.anti_highfive_image)
      },
      %Affinity{
        id: UXID.generate!(prefix: "card", size: :small),
        tgb: tgb,
        target: :houseboat,
        veracity: true,
        polarity: :positive,
        headline: Enum.at(row, @columns.pro_houseboat),
        image: Enum.at(row, @columns.pro_houseboat_image)
      },
      %Affinity{
        id: UXID.generate!(prefix: "card", size: :small),
        tgb: tgb,
        target: :houseboat,
        veracity: false,
        polarity: :positive,
        headline: Enum.at(row, @columns.pro_houseboat),
        image: Enum.at(row, @columns.pro_houseboat_image)
      },
      %Affinity{
        id: UXID.generate!(prefix: "card", size: :small),
        tgb: tgb,
        target: :houseboat,
        veracity: true,
        polarity: :negative,
        headline: Enum.at(row, @columns.anti_houseboat),
        image: Enum.at(row, @columns.anti_houseboat_image)
      },
      %Affinity{
        id: UXID.generate!(prefix: "card", size: :small),
        tgb: tgb,
        target: :houseboat,
        veracity: false,
        polarity: :negative,
        headline: Enum.at(row, @columns.anti_houseboat),
        image: Enum.at(row, @columns.anti_houseboat_image)
      },
      %{
        id: UXID.generate!(prefix: "card", size: :small),
        tgb: tgb,
        type: :conflated,
        veracity: false,
        polarity: :neutral,
        headline: Enum.at(row, @columns.conflated),
        image: Enum.at(row, @columns.conflated_image)
      },
      %{
        id: UXID.generate!(prefix: "card", size: :small),
        tgb: tgb,
        type: :conflated,
        veracity: false,
        polarity: :negative,
        headline: Enum.at(row, @columns.conflated),
        image: Enum.at(row, @columns.conflated_image)
      }
    ]
  end

  @doc """
  Probabilistically draw a card with specific constraits.

  ### Usage Examples
  ```elixir
  card = Deck.draw_card(set, type: :affinity, veracity: true, tgb: 0, target: :skub)
  "card_01J69V12V73K30"

  Deck.draw_card(set, type: :bias, veracity: true, tgb: 0, target: :red)
  "card_01J69V12V7T5J1"

  Deck.draw_card(set, type: :topical, veracity: true, tgb: 2)
  id: "card_01J69V12V7D5A1"
  ```
  """
  def draw_card(set, opts) do
    type = opts[:type]
    veracity = opts[:veracity]
    tgb = opts[:tgb]
    target = opts[:target]

    case opts[:type] do
      :topical ->
        set[{type, veracity}] |> filter_tgb(tgb) |> choose_one

      :affinity ->
        set[{type, veracity, target}] |> filter_tgb(tgb) |> choose_one

      :bias ->
        set[{type, veracity, target}] |> filter_tgb(tgb) |> choose_one

      :conflated ->
        nil
    end
  end

  defp filter_tgb(deck, tgb) do
    deck
    |> Enum.filter(&(&1.tgb <= tgb))
    |> MapSet.new()
  end

  defp filter_affinity(deck, affinity) do
    deck
    |> Enum.filter(&(&1.target == affinity))
    |> MapSet.new()
  end

  defp filter_bias(deck, bias) do
    deck
    |> Enum.filter(&(&1.target == bias))
    |> MapSet.new()
  end

  defp set(list) do
    list |> MapSet.new()
  end

  defp id_tgb(card) do
    %{id: card.id, tgb: card.tgb}
  end

  defp choose_one(list) do
    list |> Enum.shuffle() |> Enum.take(1) |> hd |> Map.get(:id)
  end

  def key(card) do
    key = {}

    key =
      key
      |> Tuple.insert_at(0, card.type)
      |> Tuple.insert_at(1, card.veracity)

    if card.type in [:affinity, :bias] do
      key |> Tuple.insert_at(2, card.target)
    else
      key
    end
  end

  @doc """
  Determines what type of card to draw.

  Returns a tuple that should be a valid key of a Store.

  [
    {:conflated, false},
    {:topical, false},
    {:topical, true},
    {:affinity, false, :cat},
    {:affinity, false, :sock},
    {:affinity, true, :cat},
    {:affinity, true, :sock},
    {:bias, false, :red},
    {:bias, false, :yellow},
    {:bias, true, :red},
    {:bias, true, :yellow}
  ]

  """
  def draw_type(opts \\ []) do
    tgb = 4

    bias_p = :rand.uniform()
    fake_p = :rand.uniform()
    draw_affinity = :rand.uniform() < 0.5
    draw_topical = not draw_affinity
    draw_true = :rand.uniform() < 1 - 1 / 10
    {bias_p, fake_p, draw_affinity, draw_topical, draw_true}
  end
end
