defmodule ViralSpiral.Canon.Deck do
  @moduledoc """

  """
  alias ViralSpiral.Canon.DrawTypeRequirements

  @set_opts_default [affinities: [:cat, :sock], biases: [:red, :yellow]]

  @doc """
  A map of MapSets.
  Every item in the MapSet is a card identifier (eg: %{id: "card_234234", tgb: 3})
  The keys of this map are of the form {type, veracity, target}
  """
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
      &Map.put(
        &2,
        &1,
        Enum.map(grouped_card[&1], fn card -> id_tgb(card) end) |> MapSet.new()
      )
    )
  end

  defp id_tgb(card) do
    %{id: card.id, tgb: card.tgb}
  end

  @spec key(atom() | %{:type => any(), :veracity => any(), optional(any()) => any()}) :: tuple()
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

  # def new() do
  #   cards = load_cards()
  #   store = create_store(cards)
  #   sets = create_sets(cards)

  #   {:ok, store, sets}
  # end

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
  def draw_card(set, draw_type) do
    type = draw_type[:type]
    veracity = draw_type[:veracity]
    tgb = draw_type[:tgb]
    target = draw_type[:target]

    case draw_type[:type] do
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

  @doc """
  Removes a card from set.
  """
  def remove_card(sets, card_type, card) do
    card_type_tuple = draw_type_opts_to_tuple(card_type)

    {_, new_sets} =
      Map.get_and_update(sets, card_type_tuple, fn set ->
        {set, MapSet.delete(set, card)}
      end)

    new_sets
  end

  defp filter_tgb(deck, tgb) do
    deck
    |> Enum.filter(&(&1.tgb <= tgb))
    |> MapSet.new()
  end

  defp choose_one(list) do
    ix = :rand.uniform(list |> Enum.to_list() |> length) - 1

    list |> Enum.at(ix)
    # |> Map.get(:id)
  end

  @doc """
  Determines what type of card to draw.

  Returns a tuple that should be a valid key of a Store.

  [type: :topical, veracity: false, tgb: 4]
  [type: :topical, veracity: true, tgb: 1]
  [type: :affinity, veracity: true, target: :skub, tgb: 2]
  [type: :bias, veracity: false, target: :yellow, tgb: 0] and so on

  deprecated : [
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

  requirements = %DrawTypeRequirements{
    tgb: 4,
    total_tgb: 10,
    biases: [:red, :blue],
    affinities: [:cat, :sock],
    current_player: %{
      identity: :blue
    }
  }
  """
  def draw_type(%DrawTypeRequirements{} = requirements) do
    type =
      case :rand.uniform() do
        a when a < 0.2 -> :bias
        a when a >= 0.2 and a < 0.6 -> :topical
        a when a >= 0.6 and a <= 1 -> :affinity
      end

    veracity =
      case :rand.uniform() do
        a when a < requirements.tgb / requirements.total_tgb -> true
        _ -> false
      end

    target =
      case type do
        :bias -> pick_one(requirements.biases, exclude: requirements.current_player.identity)
        :affinity -> pick_one(requirements.affinities)
        :topical -> nil
      end

    [type: type, veracity: veracity, tgb: requirements.tgb]
    |> then(fn type ->
      case target do
        nil -> type
        _ -> type |> Keyword.put(:target, target)
      end
    end)
  end

  def draw_type_opts_to_tuple(opts) do
    type = Keyword.get(opts, :type)
    veracity = Keyword.get(opts, :veracity)
    target = Keyword.get(opts, :target)

    {}
    |> Tuple.insert_at(0, type)
    |> Tuple.insert_at(1, veracity)
    |> then(fn type ->
      case target do
        nil -> type
        _ -> type |> Tuple.insert_at(2, target)
      end
    end)
  end

  def pick_one(list, opts \\ []) do
    exclude = opts[:exclude]
    list = list |> Enum.filter(&(&1 != exclude))

    ix = :rand.uniform(length(list)) - 1
    Enum.at(list, ix)
  end

  def link(cards, articles) do
    cards
    |> Enum.map(fn card ->
      try do
        if card.type == :conflated do
          # IO.inspect(card)
        end

        article = articles[{card.id, card.veracity}]
        %{card | article_id: article.id}
      rescue
        KeyError -> card
      end
    end)
  end

  def get_fake_card(store, card_id) when is_bitstring(card_id) do
    store[{card_id, false}]
  end

  def get_fake_card(store, card) do
    store[{card.id, false}]
  end

  def size(sets, card_type) do
    card_type_tuple = draw_type_opts_to_tuple(card_type)
    sets[card_type_tuple] |> MapSet.size()
  end
end
