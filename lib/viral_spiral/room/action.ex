defmodule ViralSpiral.Room.Action do
  alias ViralSpiral.Room.Actions.Player.PassCard
  alias ViralSpiral.Room.Actions.Player.InitiateCancel

  @doc """
  Actions initiated by players or game engine.

  to affect change to game state
  """

  defstruct type: nil, payload: nil

  @type action_payloads :: InitiateCancel.t() | PassCard.t()

  @type t :: %{
          type: atom(),
          payload: action_payloads()
        }
end
