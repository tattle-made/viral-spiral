defmodule ViralSpiral.Room.State.Player do
  @moduledoc """
  Create and update Player Score.

  ## Example
  iex> player_score = %ViralSpiral.Game.Score.Player{
      biases: %{red: 0, blue: 0},
      affinities: %{cat: 0, sock: 0},
      clout: 0
    }
  """
  alias ViralSpiral.Bias
  alias ViralSpiral.Affinity
  alias ViralSpiral.Room.State.Player
  alias ViralSpiral.Game.EngineConfig
  alias ViralSpiral.Game.Player, as: PlayerData
  import ViralSpiral.Game.EngineConfig.Guards
  alias ViralSpiral.Room.State.Change

  defstruct biases: %{}, affinities: %{}, clout: 0

  @type change_opts :: [type: :clout | :affinity | :bias, offset: integer(), target: atom()]
  @type t :: %__MODULE__{
          biases: map(),
          affinities: map(),
          clout: integer()
        }

  @spec new(t(), %ViralSpiral.Game.EngineConfig{
          :affinities => list(Affinity.t()),
          :communities => list(Bias.t())
        }) :: t()
  def new(%PlayerData{} = player, %EngineConfig{} = room_config) do
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
    alias ViralSpiral.Room.State.Player

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
    Change a Player's Score.

    Change function pattern matches depending on the function's parameter.
    The second parameter can be :clout, :affinity: :bias. These determine which score to change.
    Corresponding score is changed based on the values passed in the opts keyword list.

    The various possible values that can be passed in opts are defined later.

    ## Options to change Bias
    - target : can be :red, :blue or :yellow
    - offset : The value to increment/decrement current score by. Must be an integer.

    ## Options to change affinity
    - target : can be :sock, :houseboat, :highfive, :cat or :skub
    - offset : The value to increment/decrement current score by. Must be an integer

    ## Options to change clout
    - offset : The value to increment/decrement current score by. Must be an integer
    """
    @spec change(
            Player.t(),
            :bias,
            :blue | :red | :yellow,
            integer()
          ) :: Player.t()
    def change(%Player{} = player, :bias, target_bias, count)
        when is_community(target_bias) and is_integer(count) do
      new_biases = Map.put(player.biases, target_bias, player.biases[target_bias] + count)
      %{player | biases: new_biases}
    end

    @spec change(
            Player.t(),
            :affinity,
            :cat | :highfive | :houseboat | :skub | :sock,
            integer()
          ) :: Player.t()
    def change(%Player{} = player, :affinity, target_affinity, count)
        when is_affinity(target_affinity) and is_integer(count) do
      new_affinities =
        Map.put(player.affinities, target_affinity, player.affinities[target_affinity] + count)

      %{player | affinities: new_affinities}
    end

    @spec change(Player.t(), :clout, integer()) :: Player.t()
    def change(%Player{} = player, :clout, count) when is_integer(count) do
      new_clout = player.clout + count
      %{player | clout: new_clout}
    end
  end
end
