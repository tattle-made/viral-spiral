defmodule ViralSpiral.Entity.Turn.Change do
  defmodule NewTurn do
    alias ViralSpiral.Entity.Round
    defstruct [:round]

    @type t :: %__MODULE__{
            round: Round.t()
          }
  end

  defmodule NextTurn do
    defstruct [:target]

    @type t :: %__MODULE__{
            target: UXID.uxid_string()
          }
  end
end
