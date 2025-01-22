defmodule ViralSpiral.Entity.Player do
  @moduledoc """
  Create and update Player Score.

  ## Example
  iex> player_score = %ViralSpiral.Game.Score.Player{
      biases: %{red: 0, blue: 0},
      affinities: %{cat: 0, sock: 0},
      clout: 0
    }
  """
  alias ViralSpiral.Entity.Player.ActiveCardDoesNotExist
  alias ViralSpiral.Entity.Player.DuplicateActiveCardException
  alias ViralSpiral.Entity.Player
  alias ViralSpiral.Bias
  import ViralSpiral.Room.EngineConfig.Guards

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
          active_cards: list()
        }

  @spec set_name(Player.t(), String.t()) :: Player.t()
  def set_name(%Player{} = player, name) do
    %{player | name: name}
  end

  @spec set_identity(Player.t(), Bias.target()) :: Player.t()
  def set_identity(%Player{} = player, identity) do
    %{player | identity: identity}
  end

  def add_to_hand(%Player{} = player, card) do
    Map.put(player, :hand, player.hand ++ [card])
  end

  @spec add_active_card(Player.t(), String.t(), boolean()) :: Player.t()
  def add_active_card(%Player{} = player, card_id, veracity) do
    case Enum.find(player.active_cards, &(&1.id == card_id)) do
      nil -> Map.put(player, :active_cards, player.active_cards ++ [{card_id, veracity}])
      _ -> raise DuplicateActiveCardException
    end
  end

  @spec remove_active_card(Player.t(), String.t(), boolean()) :: Player.t()
  def remove_active_card(%Player{} = player, card_id, veracity) do
    case Enum.find(player.active_cards, &(elem(&1, 0) == card_id and elem(&1, 1) == veracity)) do
      nil -> raise ActiveCardDoesNotExist
      _ -> Map.put(player, :active_cards, List.delete(player.active_cards, {card_id, veracity}))
    end
  end

  def update_active_card(%Player{} = player, card_id, new_card) do
    ix = Enum.find_index(player.active_cards, fn x -> elem(x, 0) == card_id end)

    active_cards =
      List.replace_at(player.active_cards, ix, {card_id, new_card.veracity, new_card.headline})

    %{player | active_cards: active_cards}
  end

  def set_article(%Player{} = player, card, article) do
    case Enum.find(player.active_cards, &(&1 == card.id)) do
      nil ->
        player

      ix ->
        entry = Enum.at(player.active_cards, ix)
        new_entry = Map.put(entry, :source, article)
        Map.put(player, :active_cards, new_entry)
    end
  end
end

defimpl ViralSpiral.Entity.Change, for: ViralSpiral.Entity.Player do
  alias ViralSpiral.Affinity
  alias ViralSpiral.Bias
  alias ViralSpiral.Entity.Player
  import ViralSpiral.Room.EngineConfig.Guards

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
          Bias.target(),
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
          Affinity.target(),
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

  def apply_change(player, change_desc) do
    case change_desc[:type] do
      :clout ->
        change(player, :clout, change_desc[:offset])

      :affinity ->
        change(player, :affinity, change_desc[:target], change_desc[:offset])

      :bias ->
        change(player, :bias, change_desc[:target], change_desc[:offset])

      :add_to_hand ->
        Player.add_to_hand(player, change_desc[:card])

      :remove_from_hand ->
        player

      :add_active_card ->
        Player.add_active_card(player, change_desc[:card_id], change_desc[:veracity])

      :remove_active_card ->
        Player.remove_active_card(player, change_desc[:card_id], change_desc[:veracity])

      :set_article ->
        Player.set_article(change_desc[:card], change_desc[:article])

      :turn_card_to_fake ->
        Player.update_active_card(player, change_desc[:card].id, change_desc[:card])

      :ignore ->
        player
    end
  end
end

defmodule ViralSpiral.Entity.Player.DuplicateActiveCardException do
  defexception message: "This card is already held by the player"
end

defmodule ViralSpiral.Entity.Player.ActiveCardDoesNotExist do
  defexception message: "This card is not an active card for this player "
end

defmodule ViralSpiral.Entity.PlayerMap do
  @moduledoc """
  Functions for handling a Map of `ViralSpiral.Entity.Player` in a Room.

  Player's id is the key for each player in the provided map
  """
  import ViralSpiral.Room.EngineConfig.Guards

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
  Return all players whose identity is different from the passed player
  """
  # @spec(map(String.t(), Player.t()), String.t() :: list(Player.t()))
  def others(players, player) when is_map(players) and is_bitstring(player) do
    Map.keys(players)
    |> Enum.filter(&(&1 != player))
    |> Enum.reduce(%{}, &Map.put(&2, &1, players[&1]))
  end

  @doc """
  Convert a list of `Player` into Map suitable for `PlayerMap`.

  ## Examples :

      iex> players = [ %Player{id: "abc", identity: :red}, %Player{id: "def", identity: :yellow} ]
      [
        %ViralSpiral.Entity.Player{
          id: "abc",
          biases: %{},
          affinities: %{},
          clout: 0,
          name: "",
          identity: :red,
          hand: [],
          active_cards: []
        },
        %ViralSpiral.Entity.Player{
          id: "def",
          biases: %{},
          affinities: %{},
          clout: 0,
          name: "",
          identity: :yellow,
          hand: [],
          active_cards: []
        }
      ]
      iex> PlayerMap.to_map(players)
      %{
        def: %ViralSpiral.Entity.Player{
          id: "def",
          biases: %{},
          affinities: %{},
          clout: 0,
          name: "",
          identity: :yellow,
          hand: [],
          active_cards: []
        },
        abc: %ViralSpiral.Entity.Player{
          id: "abc",
          biases: %{},
          affinities: %{},
          clout: 0,
          name: "",
          identity: :red,
          hand: [],
          active_cards: []
        }
      }
  """
  def to_map(players) when is_list(players) do
    Enum.reduce(players, %{}, &Map.put(&2, String.to_atom(&1.id), &1))
  end

  def to_full_map(ids, players) when is_list(ids) do
    Enum.reduce(ids, %{}, &Map.put(&2, &1, players[&1]))
  end
end
