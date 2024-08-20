defmodule ViralSpiral.Score.Player do
  @moduledoc """
  Create and update Player Score.

  ## Example
  iex> player_score = %ViralSpiral.Game.Score.Player{
      biases: %{red: 0, blue: 0},
      affinities: %{cat: 0, sock: 0},
      clout: 0
    }
  """
  alias ViralSpiral.Score.Player
  alias ViralSpiral.Game.RoomConfig
  alias ViralSpiral.Game.Player, as: PlayerData
  import ViralSpiral.Game.RoomConfig.Guards
  alias ViralSpiral.Score.Change

  defstruct biases: %{}, affinities: %{}, clout: 0

  @type change_opts :: [type: :clout | :affinity | :bias, offset: integer(), target: atom()]
  @type t :: %__MODULE__{
          biases: map(),
          affinities: map(),
          clout: integer()
        }

  @spec new(ViralSpiral.Game.Player.t(), %ViralSpiral.Game.RoomConfig{
          :affinities => list(),
          :communities => list()
        }) :: ViralSpiral.Score.Player.t()
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

  defimpl Change do
    @doc """
    Implement change protocol for a Player's Score.
    """
    @spec apply_change(Player.t(), Player.change_opts()) :: Player.t()
    def apply_change(player, opts) do
      case opts[:type] do
        :clout -> change(player, :clout, opts[:offset])
        :affinity -> change(player, :affinity, opts[:target], opts[:offset])
        :bias -> change(player, :bias, opts[:target], opts[:offset])
      end
    end

    @doc """
    Change a Player's Bias.
    """
    @spec change(
            ViralSpiral.Score.Player.t(),
            :bias,
            :blue | :red | :yellow,
            integer()
          ) :: ViralSpiral.Score.Player.t()
    def change(%Player{} = player, :bias, target_bias, count)
        when is_community(target_bias) and is_integer(count) do
      new_biases = Map.put(player.biases, target_bias, player.biases[target_bias] + count)
      %{player | biases: new_biases}
    end

    @doc """
    Change a Player's Affinity.
    """
    @spec change(
            ViralSpiral.Score.Player.t(),
            :affinity,
            :cat | :highfive | :houseboat | :skub | :sock,
            integer()
          ) :: ViralSpiral.Score.Player.t()
    def change(%Player{} = player, :affinity, target_affinity, count)
        when is_affinity(target_affinity) and is_integer(count) do
      new_affinities =
        Map.put(player.affinities, target_affinity, player.affinities[target_affinity] + count)

      %{player | affinities: new_affinities}
    end

    @doc """
    Change a Player's Clout.
    """
    @spec change(ViralSpiral.Score.Player.t(), :clout, integer()) :: ViralSpiral.Score.Player.t()
    def change(%Player{} = player, :clout, count) when is_integer(count) do
      new_clout = player.clout + count
      %{player | clout: new_clout}
    end
  end
end
