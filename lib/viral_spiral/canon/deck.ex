defmodule ViralSpiral.Canon.Deck do
  @moduledoc """

  """
  alias ViralSpiral.Canon.Card.Sparse
  alias ViralSpiral.Canon.Deck.CardSet
  alias ViralSpiral.Canon.Card
  alias ViralSpiral.Canon.Deck.Set
  alias ViralSpiral.Canon.Deck

  @set_opts_default [affinities: [:cat, :sock], biases: [:red, :yellow]]

  @type card_sets :: %{
          optional(CardSet.key_type()) => list(CardSet.member())
        }

  @doc """
  A map of MapSets.
  Every item in the MapSet is a card identifier (eg: %{id: "card_234234", tgb: 3})
  The keys of this map are of the form {type, veracity, target}
  """
  @spec create_sets(list(Card.t()), keyword()) :: card_sets()
  def create_sets(cards, opts \\ @set_opts_default) do
    affinities = opts[:affinities]
    biases = opts[:biases]

    common_cards = cards |> Enum.filter(&(&1.type in [:topical, :conflated]))
    affinity_cards = cards |> Enum.filter(&(&1.type == :affinity and &1.target in affinities))
    bias_cards = cards |> Enum.filter(&(&1.type == :bias and &1.target in biases))

    cards = common_cards ++ affinity_cards ++ bias_cards

    grouped_card = cards |> Enum.group_by(&Deck.Card.key(&1))

    Enum.reduce(
      Map.keys(grouped_card),
      %{},
      &Map.put(
        &2,
        &1,
        Enum.map(grouped_card[&1], fn card -> Deck.CardSet.make_member(card) end) |> MapSet.new()
      )
    )
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
  @spec draw_card(any(), CardSet.key_type(), integer()) :: Sparse.t()
  def draw_card(card_sets, set_key, tgb) do
    {_, veracity, _} = set_key

    card_id =
      card_sets[set_key]
      |> filter_tgb(tgb)
      |> choose_one()
      |> Map.get(:id)

    Sparse.new(card_id, veracity)
  end

  defp filter_tgb(set, tgb) do
    set
    |> Enum.filter(&(&1.tgb <= tgb))
    |> MapSet.new()
  end

  defp choose_one(list) do
    ix = :rand.uniform(list |> Enum.to_list() |> length) - 1
    list |> Enum.at(ix)
    # |> Map.get(:id)
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

  defp draw_type_opts_to_tuple(opts) do
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

  def get_fake_card(store, card_id) when is_bitstring(card_id) do
    store[{card_id, false}]
  end

  def get_fake_card(store, card) do
    store[{card.id, false}]
  end

  @spec size(sets :: term(), Set.key_type()) :: non_neg_integer()
  def size(sets, set_key) do
    case sets[set_key] do
      nil -> -1
      _ -> size!(sets, set_key)
    end
  end

  @spec size(sets :: term(), Set.key_type()) :: non_neg_integer()
  def size!(sets, set_key) do
    sets[set_key]
    |> MapSet.size()
  end
end
