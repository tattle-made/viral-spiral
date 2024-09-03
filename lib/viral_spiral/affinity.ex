defmodule ViralSpiral.Affinity do
  defstruct target: nil

  @type target :: :cat | :sock | :highfive | :houseboat | :skub
  @type t :: %__MODULE__{
          target: target()
        }
end
