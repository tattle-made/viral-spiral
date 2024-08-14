defmodule ViralSpiral.Game.Score.Room do
  alias ViralSpiral.Game.Score.Room
  defstruct chaos_countdown: 10

  def new() do
    %Room{}
  end

  def countdown(%Room{} = room) do
    %{room | chaos_countdown: room.chaos_countdown - 1}
  end
end

defmodule ViralSpiral.Game.Score.Player do
  alias ViralSpiral.Game.Score.Player
  alias ViralSpiral.Game.RoomConfig
  alias ViralSpiral.Game.Player, as: PlayerData
  import ViralSpiral.Game.RoomConfig.Guards

  defstruct biases: %{}, affinities: %{}, clout: 0

  def new(%PlayerData{} = player, %RoomConfig{} = room_config) do
    bias_list = Enum.filter(room_config.communities, &(&1 != player.identity))
    bias_map = Enum.reduce(bias_list, %{}, fn x, acc -> Map.put(acc, x, 0) end)

    affinity_list = room_config.affinities
    affinity_map = Enum.reduce(affinity_list, %{}, fn x, acc -> Map.put(acc, x, 0) end)

    %Player{
      biases: bias_map,
      affinities: affinity_map
    }
  end

  def change(%Player{} = player, :bias, target_bias, count)
      when is_community(target_bias) and is_integer(count) do
    new_biases = Map.put(player.biases, target_bias, player.biases[target_bias] + count)
    %{player | biases: new_biases}
  end

  def change(%Player{} = player, :affinity, target, count)
      when is_affinity(target) and is_integer(count) do
    new_affinities = Map.put(player.affinities, target, player.affinities[target] + count)
    %{player | affinities: new_affinities}
  end

  def change(%Player{} = player, :clout, count) when is_integer(count) do
    new_clout = player.clout + count
    %{player | clout: new_clout}
  end
end
