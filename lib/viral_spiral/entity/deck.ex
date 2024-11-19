defmodule ViralSpiral.Entity.Deck do
  alias ViralSpiral.Canon.Deck, as: CanonDeck
  alias ViralSpiral.Entity.Deck
  alias ViralSpiral.Entity.Change

  defstruct available_cards: nil,
            dealt_cards: nil,
            store: nil

  @type change_opts :: [type: :remove | :shuffle]
  @type t :: %__MODULE__{
          available_cards: map(),
          dealt_cards: map(),
          store: map()
        }

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
    cards = CanonDeck.load_cards()

    %Deck{
      available_cards: CanonDeck.create_sets(cards),
      dealt_cards: %{},
      store: CanonDeck.create_store(cards)
    }
  end

  defimpl Change do
    @doc """
    Handle changes to the deck.

    Possible changes :
    - Make card unavailable for drawing. Implemted by change type :remove
    """
    # @spec apply_change(Deck.t(), Deck.change_opts()) :: Deck.t()
    def apply_change(%Deck{} = deck, change_desc) do
      case change_desc[:type] do
        :remove_card ->
          new_sets =
            CanonDeck.remove_card(
              deck.available_cards,
              change_desc[:draw_type],
              change_desc[:card_in_set]
            )

          Map.put(deck, :available_cards, new_sets)
      end
    end
  end
end
