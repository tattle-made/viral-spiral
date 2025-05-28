defmodule ViralSpiral.Room.DrawConstraints do
  alias ViralSpiral.Affinity
  alias ViralSpiral.Bias

  defstruct chaos: 0,
            total_tgb: nil,
            biases: nil,
            affinities: nil,
            current_player: %{identity: nil}

  @type t :: %__MODULE__{
          chaos: integer(),
          total_tgb: integer(),
          biases: list(Bias.target()),
          affinities: list(Affinity.target()),
          current_player: %{
            identity: Bias.target()
          }
        }
end

# defmodule ViralSpiral.Room.DrawTypeRequirements.Adapter do
#   alias ViralSpiral.Canon.DrawConstraints
#   alias ViralSpiral.Room.State

#   def new(%State{} = state) do
#     %DrawConstraints{
#       tgb: state.room
#     }
#   end
# end
