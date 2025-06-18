defmodule ViralSpiral.Room.Actions.Engine.DrawCard do
  alias ViralSpiral.Canon.Card.Sparse

  @type t :: %__MODULE__{
          card: Sparse.t()
        }
  defstruct card: nil
end
