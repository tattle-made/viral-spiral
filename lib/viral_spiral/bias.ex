defmodule ViralSpiral.Bias do
  defstruct target: nil

  @type target :: :red | :yellow | :blue
  @type t :: %__MODULE__{
          target: target()
        }
end
