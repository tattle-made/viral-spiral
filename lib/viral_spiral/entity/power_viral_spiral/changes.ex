defmodule ViralSpiral.Entity.PowerViralSpiral.Changes do
  defmodule InitiateViralSpiral do
    alias ViralSpiral.Canon.Card.Sparse
    alias ViralSpiral.Bias
    defstruct [:from_id, :to, :bias, :card]

    @type t :: %__MODULE__{
            from_id: UXID.uxid_string(),
            to: list(UXID.uxid_string()),
            bias: Bias.t(),
            card: Sparse.t()
          }
  end

  defmodule PassCardViralSpiral do
    defstruct [:from_id, :to_id]
  end

  defmodule KeepCardViralSpiral do
    defstruct [:from_id]
  end

  defmodule DiscardCardViralSpiral do
    defstruct [:from_id]
  end
end
