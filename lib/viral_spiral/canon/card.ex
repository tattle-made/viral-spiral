defmodule ViralSpiral.Canon.Card do
  alias ViralSpiral.Canon.Card.Bias
  alias ViralSpiral.Affinity

  @type t :: Affinity.t() | Bias.t()
end

defmodule ViralSpiral.Canon.Card.Sparse do
  alias ViralSpiral.Canon.Card
  alias ViralSpiral.Canon.Card.Sparse
  defstruct id: nil, veracity: nil, headline: nil

  @type t :: %__MODULE__{
          id: String.t(),
          veracity: boolean()
        }

  def new({id, veracity}) when is_bitstring(id) and is_boolean(veracity) do
    %Sparse{
      id: id,
      veracity: veracity
    }
  end

  def new(id, veracity, headline) when is_bitstring(id) and is_boolean(veracity) do
    %Sparse{
      id: id,
      veracity: veracity,
      headline: headline
    }
  end
end
