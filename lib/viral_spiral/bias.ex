defmodule ViralSpiral.Bias do
  alias ViralSpiral.Bias
  import ViralSpiral.Room.EngineConfig.Guards
  defstruct target: nil

  @type target :: :red | :yellow | :blue
  @type t :: %__MODULE__{
          target: target()
        }

  @labels %{
    red: "Red",
    yellow: "Yellow",
    blue: "Blue"
  }

  def label(target) when is_community(target) do
    @labels[target]
  end

  def label(%Bias{} = affinity) do
    @labels[affinity.target]
  end

  @spec valid?(atom()) :: boolean()
  def valid?(bias) do
    bias in Map.keys(@labels)
  end
end
