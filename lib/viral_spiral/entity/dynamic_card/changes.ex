defmodule ViralSpiral.Entity.DynamicCard.Changes do
  defmodule AddIdentityStats do
    alias ViralSpiral.Canon.Card.Sparse
    defstruct [:card, :identity_stats]

    @type t :: %__MODULE__{
            card: Sparse.t(),
            identity_stats: map()
          }
  end
end
