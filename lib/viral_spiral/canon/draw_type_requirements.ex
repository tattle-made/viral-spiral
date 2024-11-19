defmodule ViralSpiral.Canon.DrawTypeRequirements do
  alias ViralSpiral.Affinity
  alias ViralSpiral.Bias

  defstruct tgb: 0,
            total_tgb: nil,
            biases: nil,
            affinities: nil,
            current_player: %{identity: nil}

  @type t :: %__MODULE__{
          tgb: integer(),
          total_tgb: integer(),
          biases: list(Bias.target()),
          affinities: list(Affinity.target()),
          current_player: %{
            identity: Bias.target()
          }
        }
end

defmodule ViralSpiral.Canon.DrawTypeRequirements.Adapter do
  alias ViralSpiral.Canon.DrawTypeRequirements
  alias ViralSpiral.Room.State

  def new(%State{} = state) do
    %DrawTypeRequirements{
      tgb: state.room
    }
  end
end
