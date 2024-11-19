defmodule ViralSpiral.Gameplay.Factory do
  @moduledoc """
  Create entities for a Game Room
  """
  alias ViralSpiral.Entity.Deck
  alias ViralSpiral.Canon.Deck, as: CanonDeck
  alias ViralSpiral.Canon.DrawTypeRequirements
  alias ViralSpiral.Room.State
  alias ViralSpiral.Room.EngineConfig
  alias ViralSpiral.Entity.Player
  alias ViralSpiral.Entity.Room

  def new_room() do
    engine_config = %EngineConfig{}

    %Room{
      id: UXID.generate!(prefix: "room", size: :small),
      name: Room.name(),
      state: :uninitialized,
      chaos_counter: engine_config.chaos_counter,
      volatality: engine_config.volatility
    }
  end

  @doc """
  Create a new player whose properties conform with the Room settings.
  """
  @spec new_player_for_room(Room.t()) :: Player.t()
  def new_player_for_room(%Room{} = room) do
    identity = Enum.shuffle(room.communities) |> Enum.at(0)

    bias_list = Enum.filter(room.communities, &(&1 != identity))
    bias_map = Enum.reduce(bias_list, %{}, fn x, acc -> Map.put(acc, x, 0) end)

    affinity_list = room.affinities
    affinity_map = Enum.reduce(affinity_list, %{}, fn x, acc -> Map.put(acc, x, 0) end)

    %Player{
      id: UXID.generate!(prefix: "player", size: :small),
      identity: identity,
      biases: bias_map,
      affinities: affinity_map,
      clout: 0
    }
  end

  def draw_type(%State{} = state) do
    %DrawTypeRequirements{
      tgb: state.room.chaos,
      total_tgb: state.room.chaos_counter,
      biases: state.room.communities,
      affinities: state.room.affinities,
      current_player: %{
        identity: State.current_round_player(state).identity
      }
    }
  end

  def new_deck(%Room{} = room) do
    cards = CanonDeck.load_cards()

    set_opts = [
      affinities: room.affinities,
      biases: room.communities
    ]

    %Deck{
      available_cards: CanonDeck.create_sets(cards, set_opts),
      dealt_cards: %{},
      store: CanonDeck.create_store(cards)
    }
  end
end
