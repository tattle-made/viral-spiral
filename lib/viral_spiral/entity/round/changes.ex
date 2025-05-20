defmodule ViralSpiral.Entity.Round.Changes do
  defmodule NextRound do
    defstruct []

    @type t :: %__MODULE__{}
  end

  defmodule SkipRound do
    defstruct [:player_id]

    @type t :: %__MODULE__{
            player_id: UXID.uxid_string()
          }
  end
end
