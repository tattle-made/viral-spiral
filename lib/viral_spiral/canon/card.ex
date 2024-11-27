defmodule ViralSpiral.Canon.Card do
  alias ViralSpiral.Canon.Card.Bias
  alias ViralSpiral.Affinity

  @type t :: Affinity.t() | Bias.t()
end

defmodule ViralSpiral.Canon.Card.Sparse do
  defstruct id: nil, veracity: nil

  @type t :: %__MODULE__{
          id: String.t(),
          veracity: boolean()
        }
end
