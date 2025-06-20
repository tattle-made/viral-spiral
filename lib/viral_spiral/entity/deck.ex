defmodule ViralSpiral.Entity.Deck do
  alias ViralSpiral.Canon
  alias ViralSpiral.Canon.Encyclopedia
  alias ViralSpiral.Canon.Deck, as: CanonDeck
  alias ViralSpiral.Entity.Deck
  alias ViralSpiral.Entity.Change

  @derive {Inspect, only: [:dealt_cards]}
  defstruct available_cards: nil,
            dealt_cards: nil,
            store: nil,
            article_store: nil

  @type change_opts :: [type: :remove | :shuffle]
  @type t :: %__MODULE__{
          available_cards: map(),
          dealt_cards: map(),
          store: map(),
          article_store: map()
        }

  @card_attrs_default [affinities: [:cat, :sock], biases: [:red, :yellow]]

  @doc """
  todo : datastructure of cards,  optimized for game operations
  """
  def new(cards) do
    %Deck{
      available_cards: MapSet.new(cards),
      dealt_cards: %{}
    }
  end

  def new() do
    {_card_store, card_sets, _, _article_store} = Canon.setup()

    %Deck{
      available_cards: card_sets,
      dealt_cards: %{}
    }
  end

  def skeleton(card_attrs \\ @card_attrs_default) do
    {_card_store, card_sets, _, _article_store} = Canon.setup(card_attrs)

    %Deck{
      available_cards: card_sets,
      dealt_cards: %{}
    }
  end

  defimpl Change do
    alias ViralSpiral.Entity.Deck.Changes.RemoveCard

    def change(%Deck{} = deck, %RemoveCard{} = change) do
      new_set = Canon.remove_card_from_deck(change.card_sets, change.card_type, change.card)
      Map.put(deck, :available_cards, new_set)
    end
  end
end
