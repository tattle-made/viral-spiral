defmodule ViralSpiral.Entity.Player.Map do
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
  Return ids of players who like/dislike the same thing.

  For instance, to get all players who like cats, call `of_same_affinity_polarity(players, :cat, :positive)`.
  To get all players who hate skubs, call `of_same_affinity_polarity(players, :skub, :negative)`
  """
  def of_same_affinity_polarity(players, affinity, polarity)
      when is_map(players) and is_affinity(affinity) and polarity in [:positive, :negative] do
  end

  def of_opposite_affinity_polarity(players, affinity) when is_affinity(affinity) do
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
