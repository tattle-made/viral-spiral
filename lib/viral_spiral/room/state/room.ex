defmodule ViralSpiral.Room.State.Room do
  @moduledoc """
  Room specific configuration for every game.
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
            state: :uninitialized

  @all_states [:uninitialized, :waiting_for_players, :running, :paused]

  @type states :: :uninitialized | :waiting_for_players | :running | :paused
  @type t :: %__MODULE__{
          affinities: list(Affinity.target()),
          communities: list(Bias.target()),
          chaos_counter: integer(),
          volatality: EngineConfig.volatility(),
          id: String.t(),
          name: String.t(),
          state: states()
        }

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
      :chaos_coutdown -> Map.put(score, :chaos_couter, score.chaos_counter + opts[:offset])
    end
  end
end
