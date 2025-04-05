defprotocol ViralSpiral.Entity.Change do
  @moduledoc """
  Protocol to change Entity used in Viral Spiral.

  ## Fields
  - score: struct which implements the `Change` protocol
  - change_description: a Keyword List with parameters defining the change
  """

  # def apply_change(state, change_desc)

  def change(entity, change)

  defmodule UndefinedChange do
    defexception [:message]
  end
end
