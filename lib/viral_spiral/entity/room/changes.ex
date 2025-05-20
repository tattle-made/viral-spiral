defmodule ViralSpiral.Entity.Room.Changes do
  defmodule ReserveRoom do
    defstruct [:player_name]

    @type t :: %__MODULE__{
            player_name: String.t()
          }
  end

  defmodule JoinRoom do
    defstruct [:player_name]

    @type t :: %__MODULE__{
            player_name: String.t()
          }
  end

  defmodule StartGame do
    defstruct []

    @type t :: %__MODULE__{}
  end

  defmodule ChangeCountdown do
    defstruct [:offset]

    @type t :: %__MODULE__{}
  end

  defmodule ResetUnjoinedPlayers do
    defstruct []

    @type t :: %__MODULE__{}
  end
end
