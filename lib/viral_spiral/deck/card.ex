defmodule ViralSpiral.Deck.Card do
  import ViralSpiral.Deck.CardGuards
  alias ViralSpiral.Deck.Card

  defstruct id: nil,
            type: nil

  @type card_types :: :affinity | :bias | :topical | :conflated

  @type t :: %__MODULE__{
          id: String.t(),
          type: card_types()
        }

  def new(type) when is_card_type(type) do
    %Card{
      id: UXID.generate!(prefix: "card", size: :small),
      type: type
    }
  end
end
