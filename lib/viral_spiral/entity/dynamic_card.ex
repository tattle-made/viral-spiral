defmodule ViralSpiral.Entity.DynamicCard do
  alias ViralSpiral.Canon.Card.Sparse
  alias ViralSpiral.Entity.DynamicCard
  alias ViralSpiral.Entity.Change

  defstruct [:identity_stats]

  @type t :: %__MODULE__{
          identity_stats: %{optional(Sparse.t()) => map()}
        }

  def skeleton() do
    %DynamicCard{
      identity_stats: %{}
    }
  end

  defimpl Change do
    alias ViralSpiral.Entity.DynamicCard.Changes.AddIdentityStats

    def change(dynamic_card, %AddIdentityStats{} = change) do
      new_identity_stats =
        Map.put(dynamic_card.identity_stats, change.card, change.identity_stats)

      %{dynamic_card | identity_stats: new_identity_stats}
    end
  end
end
