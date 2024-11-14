defmodule ViralSpiral.Canon.Deck.DrawTypeRequirements do
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

defmodule ViralSpiral.Canon.Deck.DrawTypeRequirements.Adapter do
  alias ViralSpiral.Canon.Deck.DrawTypeRequirements
  alias ViralSpiral.Room.State.Root

  def new(%Root{} = state) do
    %DrawTypeRequirements{
      tgb: state.room
    }
  end
end
