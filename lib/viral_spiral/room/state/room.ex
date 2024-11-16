defmodule ViralSpiral.Room.State.Room do
  @moduledoc """
  Room specific configuration for every game.

  ## Room States
  - :reserved : When a player has expressed an interest to play the game but their friends haven't joined the room yet or the player hasn't explicitly told us to start the game.
  """
  alias ViralSpiral.Bias
  alias ViralSpiral.Affinity
  alias ViralSpiral.Room.State.Room
  alias ViralSpiral.Game.EngineConfig

  defstruct affinities: [],
            communities: [],
            chaos_counter: nil,
            volatality: :medium,
            id: nil,
            name: nil,
            state: :uninitialized,
            chaos: nil

  @all_states [:reserved, :uninitialized, :waiting_for_players, :running, :paused]

  @type states :: :reserved | :uninitialized | :waiting_for_players | :running | :paused
  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          state: states(),
          affinities: list(Affinity.target()),
          communities: list(Bias.target()),
          chaos_counter: integer(),
          chaos: integer(),
          volatality: EngineConfig.volatility()
        }

  @doc """
  Reserve a room.

  A player can reserve a room, share its URL with their friends and wait for them to join the room.
  """
  @spec reserve(String.t()) :: Room.t()
  def reserve(name) when is_bitstring(name) do
    %Room{
      id: UXID.generate!(prefix: "room", size: :small),
      name: name,
      state: :reserved
    }
  end

  def new(player_count) do
    engine_config = %EngineConfig{}

    affinities = engine_config.affinities
    total_affinities = length(affinities)

    two_affinities =
      Stream.repeatedly(fn -> :rand.uniform(total_affinities - 1) end)
      |> Stream.dedup()
      |> Enum.take(2)

    room_affinities = Enum.map(two_affinities, &Enum.at(affinities, &1))

    communities = engine_config.communities

    room_communities =
      case player_count do
        x when x <= 3 -> Enum.shuffle(communities) |> Enum.take(2)
        _ -> communities
      end

    %Room{
      id: UXID.generate!(prefix: "room", size: :small),
      state: :uninitialized,
      affinities: room_affinities,
      communities: room_communities,
      chaos_counter: engine_config.chaos_counter,
      chaos: engine_config.chaos_counter,
      volatality: engine_config.volatility
    }
  end

  def new() do
    engine_config = %EngineConfig{}

    %Room{
      id: UXID.generate!(prefix: "room", size: :small),
      name: name(),
      state: :uninitialized,
      chaos_counter: engine_config.chaos_counter,
      volatality: engine_config.volatility
    }
  end

  def set_state(%Room{} = room, state) when state in @all_states do
    %{room | state: state}
  end

  @doc """
  Reduce the chaos countdown by 1.
  """
  @spec countdown(t()) :: t()
  def countdown(%Room{} = room) do
    %{room | chaos_counter: room.chaos_counter - 1}
  end

  def name() do
    adjectives = [
      "ambitious",
      "basic",
      "careful",
      "dark",
      "eager",
      "fab",
      "glib",
      "happy",
      "inept",
      "jolly",
      "keen",
      "lavish",
      "magic",
      "neat",
      "official",
      "perfect",
      "quack",
      "rare",
      "sassy",
      "tall",
      "velvet",
      "weak"
    ]

    nouns = [
      "apple",
      "ball",
      "cat",
      "dog",
      "eel",
      "fish",
      "goat",
      "hen",
      "island",
      "joker",
      "lion",
      "monk",
      "nose",
      "oven",
      "parrot",
      "queen",
      "rat",
      "sun",
      "tower",
      "umbrella",
      "venus",
      "water",
      "zebra"
    ]

    Enum.random(adjectives) <> "-" <> Enum.random(nouns)
  end

  def start(%Room{} = room, player_count) do
    engine_config = %EngineConfig{}

    affinities = engine_config.affinities
    total_affinities = length(affinities)

    two_affinities =
      Stream.repeatedly(fn -> :rand.uniform(total_affinities - 1) end)
      |> Stream.dedup()
      |> Enum.take(2)

    room_affinities = Enum.map(two_affinities, &Enum.at(affinities, &1))

    communities = engine_config.communities

    room_communities =
      case player_count do
        x when x <= 3 -> Enum.shuffle(communities) |> Enum.take(2)
        _ -> communities
      end

    %{room | affinities: room_affinities, communities: room_communities, state: :running}
  end
end

defimpl ViralSpiral.Room.State.Change, for: ViralSpiral.Room.State.Room do
  alias ViralSpiral.Game.State
  alias ViralSpiral.Room.State.Room

  @doc """
  Change state of a Room.
  """
  @spec apply_change(Room.t(), State.t(), keyword()) :: Room.t()
  def apply_change(%Room{} = score, _global_state, opts) do
    opts = Keyword.validate!(opts, type: nil, offset: 0)

    case opts[:type] do
      :chaos_countdown -> Map.put(score, :chaos, score.chaos + opts[:offset])
    end
  end
end
