defmodule ViralSpiral.Room.Action do
  @doc """
  Actions initiated by players or game engine.

  to affect change to game state
  """

  defstruct type: nil, payload: nil

  @type t :: %{
          type: atom(),
          payload: map()
        }
end
