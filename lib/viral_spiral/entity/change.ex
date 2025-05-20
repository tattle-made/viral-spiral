defprotocol ViralSpiral.Entity.Change do
  @moduledoc """
  Protocol to change entities used in Viral Spiral.

  Allowed values for change are defined in an entity's changes.ex file.
  """

  # def apply_change(state, change_desc)

  def change(entity, change)

  defmodule UndefinedChange do
    defexception [:message]
  end

  defmodule IllegalChange do
    defexception [:message]
  end
end
