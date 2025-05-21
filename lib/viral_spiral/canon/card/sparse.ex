defmodule ViralSpiral.Canon.Card.Sparse do
  @moduledoc """
  A sparse representation of a Card.

  A Card in viral spiral is uniquely identified by a combination of its id and veracity. As a result using only an id field in the Card struct would not suffice. Storing all the fields of a Card in the state seemed wasteful memory wise. Sparse Card fills that need. It is useful for storing in state and other state related operations.
  """
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

  def new(id, veracity) when is_bitstring(id) and is_boolean(veracity) do
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

  def new(%{id: id, veracity: veracity}) when is_bitstring(id) and is_boolean(veracity) do
    %Sparse{
      id: id,
      veracity: veracity
    }
  end
end
