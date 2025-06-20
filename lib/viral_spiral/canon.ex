defmodule ViralSpiral.Canon do
  @moduledoc """
  Loads game related assets from external source into structs.

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

  Store is a Map of all cards. Keys in this Map are unique ids for every card and their veracity (eg: {"card_234234", true}) and the values are cards (`ViralSpiral.Canon.Card.Affinity`, `ViralSpiral.Canon.Card.Bias`, `ViralSpiral.Canon.Card.Topical` and `ViralSpiral.Canon.Card.Conflated`).

  Sets is a Map of cards. Keys of this Map are a tuple of the form `{type, veracity, target}`. Value of this Map is `MapSet` of cards. For instance, for a room where the active affinities are :cat and :sock; and the active communities are :red and :yellow; the Sets would have the following keys :
  ```elixir
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
  ```


  ## Example Usage
  ```elixir
  cards = Deck.load_cards()
  store = Deck.create_store(cards)
  sets = Deck.create_sets(cards)

  requirements = %{
    tgb: 4,
    total_tgb: 10,
    biases: [:red, :blue],
    affinities: [:cat, :sock],
    current_player: %{
      identity: :blue
    }
  }
  # or
  requirements = CardDrawSpec.new(game_state)

  card_opts = Deck.draw_type(requirements)

  card_id = Deck.draw_card(sets, card_opts)

  # Some detailed example of drawing cards with specific characteristics
  card_id = Deck.draw_card(sets, type: :affinity, veracity: true, tgb: 0, target: :skub)
  card_id = Deck.draw_card(sets, type: :bias, veracity: true, tgb: 0, target: :red)
  card_id = Deck.draw_card(sets, type: :topical, veracity: true, tgb: 0)

  card_data = store[card_id]
  ```
  Read documentation of `draw_card` to see more examples of the responses.
  """
  alias ViralSpiral.Canon
  alias ViralSpiral.Canon.{Card, Deck, Encyclopedia}
  alias ViralSpiral.Canon.Card.{Sparse}
  import ViralSpiral.Canon.Card.Guards

  @card_attrs_default [affinities: [:cat, :sock], biases: [:red, :yellow]]

  @card_store Card.load() |> Card.create_store()
  @article_store Encyclopedia.load_articles() |> Encyclopedia.create_store()

  def setup(card_attrs \\ @card_attrs_default) do
    cards = Card.load()
    card_store = Card.create_store(cards)
    articles = Encyclopedia.load_articles()
    article_store = Encyclopedia.create_store(articles)

    cards = link(cards, article_store)
    card_sets = Deck.create_sets(cards, card_attrs)

    {card_store, card_sets, articles, article_store}
  end

  @doc """
  Return a sparse representation of a card for storing in state
  """
  @spec sparse_card(Card.t()) :: Sparse.t()
  def sparse_card(card) when is_card(card) do
    Sparse.new(card.id, card.veracity)
  end

  defdelegate draw_card_from_deck(card_sets, set_key, chaos), to: Deck, as: :draw_card

  defdelegate remove_card_from_deck(card_sets, set_key, member_card_sets),
    to: Deck,
    as: :remove_card

  defdelegate deck_size(card_sets, set_key), to: Deck, as: :size

  def get_article(article_store, %Sparse{} = card) do
    Encyclopedia.get_article_by_card(article_store, card)
  end

  def get_fake_card_from_card_store(store, card_id) when is_bitstring(card_id) do
    store[Sparse.new(card_id, false)]
  end

  def get_fake_card_from_card_store(store, card) do
    store[Sparse.new(card.id, false)]
  end

  @doc """
  Find matching article for cards and add its id to the corresponding Card struct.
  """
  @spec link(list(Card.t()), any()) :: list(Card.t())
  defp link(cards, articles) do
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

  def get_card_store(), do: @card_store

  def get_article_store(), do: @article_store

  def get_card_from_store(%Sparse{} = sparse_card) do
    @card_store[sparse_card]
  end

  def get_article_from_store(%Sparse{} = sparse_card) do
    Encyclopedia.get_article_by_card(@article_store, sparse_card)
  end
end
