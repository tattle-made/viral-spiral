defmodule ViralSpiral.Room.RoomConfig do
  @moduledoc """
  Room specific configuration for every game.
  """
  alias ViralSpiral.Bias
  alias ViralSpiral.Affinity
  alias ViralSpiral.Room.RoomConfig
  alias ViralSpiral.Game.EngineConfig

  defstruct affinities: [], communities: [], chaos_counter: 0, volatality: :medium

  @type t :: %__MODULE__{
          affinities: list(Affinity.target()),
          communities: list(Bias.target()),
          chaos_counter: integer(),
          volatality: EngineConfig.volatility()
        }

  def new(player_count) do
    engine_config = %EngineConfig{}

    affinities = engine_config.affinities
    total_affinities = length(affinities)

    two_affinities =
      Stream.repeatedly(fn -> :rand.uniform(total_affinities - 1) end) |> Enum.take(2)

    room_affinities = Enum.map(two_affinities, &Enum.at(affinities, &1))

    communities = engine_config.communities
    total_communities = length(communities)

    room_communities =
      case total_communities do
        x when x <= 3 -> Enum.shuffle(communities) |> Enum.take(2)
        _ -> communities
      end

    %RoomConfig{
      affinities: room_affinities,
      communities: room_communities,
      chaos_counter: engine_config.chaos_counter,
      volatality: engine_config.volatility
    }
  end
end
