defmodule ViralSpiral.Entity.PowerViralSpiral.Changes do
  defmodule InitiateViralSpiral do
    alias ViralSpiral.Canon.Card.Sparse
    defstruct [:from_id, :to_id, :card]

    @type t :: %__MODULE__{
            from_id: UXID.uxid_string(),
            to_id: UXID.uxid_string(),
            card: Sparse.t()
          }
  end
end
