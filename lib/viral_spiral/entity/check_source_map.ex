defmodule ViralSpiral.Entity.CheckSource do
  alias ViralSpiral.Entity.Change
  alias ViralSpiral.Entity.CheckSource

  defstruct [:map]

  @type t :: %__MODULE__{
          map: %{optional(String.t()) => CheckSource.t()}
        }

  def new() do
    %CheckSource{map: %{}}
  end

  defimpl Change do
    def apply_change(check_source, change_desc) do
      case change_desc[:type] do
        :put ->
          %{
            check_source
            | map: Map.put(check_source.map, change_desc[:key], change_desc[:source])
          }

        :drop ->
          %{
            check_source
            | map: Map.drop(check_source.map, [change_desc[:key]])
          }
      end
    end
  end
end
