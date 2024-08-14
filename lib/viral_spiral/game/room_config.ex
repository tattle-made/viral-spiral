defmodule ViralSpiral.Game.RoomConfig do
  defstruct affinities: [:cat, :sock],
            communities: [:red, :yellow, :blue],
            chaos_counter: 10,
            volatility: :medium
end

defmodule ViralSpiral.Game.RoomConfig.Guards do
  @affinities [:cat, :sock, :highfive, :houseboat, :skub]
  @communities [:red, :yellow, :blue]

  defguard is_affinity(value) when value in @affinities

  defguard is_community(value) when value in @communities
end
