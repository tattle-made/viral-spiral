defmodule ViralSpiralWeb.GameRoom.State do
  defstruct room: %{}, players: []

  @type t :: %__MODULE__{
          room: %{
            name: String.t(),
            chaos: integer()
          },
          players:
            list(%{
              name: String.t(),
              affinities: %{atom() => integer()}
            })
        }
end
