defmodule ViralSpiral.Room.StateChangeLogger do
  alias ViralSpiral.Room.StateChangeLogger
  defstruct message: []

  @type t :: %__MODULE__{
          message: list(String.t())
        }

  def add(%StateChangeLogger{} = logger, message) when is_bitstring(message) do
    %{logger | message: logger.message ++ message}
  end
end
