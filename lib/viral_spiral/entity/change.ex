defprotocol ViralSpiral.Entity.Change do
  @moduledoc """
  Protocol to change Entity used in Viral Spiral.

  ## Fields
  - score: struct which implements the `Change` protocol
  - change_description: a Keyword List with parameters defining the change
  """
  alias ViralSpiral.Room.State

  @spec apply_change(t(), State.t(), keyword()) :: t()
  def apply_change(state, global_state, change_description)
end

defmodule ViralSpiral.Entity.ChangeOptions do
  defstruct type: nil,
            target: nil,
            id: nil,
            extra: nil

  @type t :: %__MODULE__{
          type: atom(),
          target: atom(),
          id: String.t(),
          extra: any()
        }
end
