defmodule ViralSpiral.Room.State.Deck do
  alias ViralSpiral.Room.State.Deck
  alias ViralSpiral.Room.State.Change

  defstruct available_cards: nil,
            dealt_cards: nil

  @type change_opts :: [type: :remove | :shuffle]
  @type t :: %__MODULE__{
          available_cards: MapSet.t(),
          dealt_cards: MapSet.t()
        }

  @doc """
  todo : datastructure of cards, optimized for game operations
  """
  def new(cards) do
    %Deck{
      available_cards: MapSet.new(cards),
      dealt_cards: MapSet.new()
    }
  end

  defimpl Change do
    @doc """
    Handle changes to the deck.

    Possible changes :
    - Make card unavailable for drawing. Implemted by change type :remove
    - Shuffle card. Implemented by change type :shuffle
    """
    # @spec apply_change(Deck.t(), Deck.change_opts()) :: Deck.t()
    def apply_change(%Deck{} = deck, global_state, opts) do
      case opts[:type] do
        :remove ->
          Map.put(deck, :available_cards, MapSet.difference(deck.available_cards, opts[:target]))

        :shuffle ->
          Map.put(deck, :availabe_cards, Enum.shuffle(deck))
      end
    end
  end
end
