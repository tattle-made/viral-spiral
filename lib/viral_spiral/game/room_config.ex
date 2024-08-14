defmodule ViralSpiral.Game.RoomConfig do
  alias ViralSpiral.Game.RoomConfig

  defstruct affinities: Application.compile_env(:viral_spiral, RoomConfig)[:affinities],
            communities: Application.compile_env(:viral_spiral, RoomConfig)[:communities],
            chaos_counter: Application.compile_env(:viral_spiral, RoomConfig)[:chaos_counter],
            volatility: Application.compile_env(:viral_spiral, RoomConfig)[:volatility]
end

defmodule ViralSpiral.Game.RoomConfig.Guards do
  alias ViralSpiral.Game.RoomConfig
  @affinities Application.compile_env(:viral_spiral, RoomConfig)[:affinities]
  @communities Application.compile_env(:viral_spiral, RoomConfig)[:communities]

  defguard is_affinity(value) when value in @affinities

  defguard is_community(value) when value in @communities
end
