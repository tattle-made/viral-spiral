defprotocol ViralSpiral.Room.State.Change do
  @moduledoc """
  Protocol to change scores used in Viral Spiral.

  ## Fields
  - score: struct which implements the `Change` protocol
  - change_description: a Keyword List with parameters defining the change
  """
  @spec apply_change(t(), keyword()) :: t()
  def apply_change(score, change_description)
end
