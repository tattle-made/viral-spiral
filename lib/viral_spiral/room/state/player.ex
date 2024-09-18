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
  alias ViralSpiral.Room
  alias ViralSpiral.Room.State.Room
  alias ViralSpiral.Room.State.Player.ActiveCardDoesNotExist
  alias ViralSpiral.Room.State.Player.DuplicateActiveCardException
  alias ViralSpiral.Room.State.Player
  alias ViralSpiral.Bias
  alias ViralSpiral.Game.EngineConfig
  import ViralSpiral.Game.EngineConfig.Guards

  defstruct id: nil,
            biases: %{},
            affinities: %{},
            clout: 0,
            name: "",
            identity: nil,
            hand: [],
            active_cards: []

  @type change_opts :: [type: :clout | :affinity | :bias, offset: integer(), target: atom()]
  @type t :: %__MODULE__{
          id: String.t(),
          biases: map(),
          affinities: map(),
          clout: integer(),
          name: String.t(),
          identity: Bias.target(),
          hand: list(),
          active_cards: list(String.t())
        }

  @spec new(Room.t()) :: t()
  def new(%Room{} = room_config) do
    identity = Enum.shuffle(room_config.communities) |> Enum.at(0)

    bias_list = Enum.filter(room_config.communities, &(&1 != identity))
    bias_map = Enum.reduce(bias_list, %{}, fn x, acc -> Map.put(acc, x, 0) end)

    affinity_list = room_config.affinities
    affinity_map = Enum.reduce(affinity_list, %{}, fn x, acc -> Map.put(acc, x, 0) end)

    %Player{
      id: UXID.generate!(prefix: "player", size: :small),
      identity: identity,
      biases: bias_map,
      affinities: affinity_map,
      clout: 0
    }
  end

  @spec set_name(Player.t(), String.t()) :: Player.t()
  def set_name(%Player{} = player, name) do
    %{player | name: name}
  end

  @spec set_identity(Player.t(), Bias.target()) :: Player.t()
  def set_identity(%Player{} = player, identity) do
    %{player | identity: identity}
  end

  @spec identity(Player.t()) :: Bias.target() | nil
  def identity(%Player{} = player) do
    player.identity
  end

  def add_to_hand(%Player{} = player, card_id) do
    Map.put(player, :hand, player.hand ++ [card_id])
  end

  @spec add_active_card(Player.t(), String.t()) :: Player.t()
  def add_active_card(%Player{} = player, card_id) do
    case Enum.find(player.active_cards, &(&1 == card_id)) do
      nil -> Map.put(player, :active_cards, player.active_cards ++ [card_id])
      _ -> raise DuplicateActiveCardException
    end
  end

  @spec remove_active_card(Player.t(), String.t()) :: Player.t()
  def remove_active_card(%Player{} = player, card_id) do
    case Enum.find(player.active_cards, &(&1 == card_id)) do
      nil -> raise ActiveCardDoesNotExist
      _ -> Map.put(player, :active_cards, List.delete(player.active_cards, card_id))
    end
  end

  def clout(%Player{} = player), do: player.clout

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

defimpl ViralSpiral.Room.State.Change, for: ViralSpiral.Room.State.Player do
  alias ViralSpiral.Room.State.Player

  def apply_change(player, _game_state, change_desc) do
    case change_desc[:type] do
      :clout -> Player.change(player, :clout, change_desc[:offset])
      :affinity -> Player.change(player, :affinity, change_desc[:target], change_desc[:offset])
      :bias -> Player.change(player, :bias, change_desc[:target], change_desc[:offset])
      :add_to_hand -> Player.add_to_hand(player, change_desc[:card_id])
      :remove_from_hand -> player
      :add_active_card -> Player.add_active_card(player, change_desc[:card_id])
      :remove_active_card -> Player.remove_active_card(player, change_desc[:card_id])
    end
  end
end

defmodule ViralSpiral.Room.State.Player.DuplicateActiveCardException do
  defexception message: "This card is already held by the player"
end

defmodule ViralSpiral.Room.State.Player.ActiveCardDoesNotExist do
  defexception message: "This card is not an active card for this player "
end

defmodule ViralSpiral.Room.State.Players do
  @moduledoc """
  Functions for handling a collection of `ViralSpiral.Room.State.Player`
  """
  alias ViralSpiral.Room.State.Player
  import ViralSpiral.Game.EngineConfig.Guards

  @doc """
  Return all players of an identity
  """
  def of_identity(players, identity) when is_community(identity) and is_map(players) do
    Map.keys(players)
    |> Enum.filter(&(players[&1].identity == identity))
    |> to_full_map(players)
  end

  @doc """
  Return all players not of an identity
  """
  def not_of_identity(players, identity) when is_community(identity) and is_map(players) do
    Map.keys(players)
    |> Enum.filter(&(players[&1].identity != identity))
  end

  @doc """
  Return all players other than me
  """
  # @spec(map(String.t(), Player.t()), String.t() :: list(Player.t()))
  def others(players, me) when is_map(players) and is_bitstring(me) do
    Map.keys(players)
    |> Enum.filter(&(&1 != me))
    |> Enum.reduce(%{}, &Map.put(&2, &1, players[&1]))
  end

  def to_map(players) when is_list(players) do
    Enum.reduce(players, %{}, &Map.put(&2, &1.id, &1))
  end

  def to_full_map(ids, players) when is_list(ids) do
    Enum.reduce(ids, %{}, &Map.put(&2, &1, players[&1]))
  end
end
