defmodule ViralSpiral.Entity.Room do
  @moduledoc """
  Room specific configuration for every game.

  ## Room States
  - :reserved : When a player has expressed an interest to play the game but their friends haven't joined the room yet or the player hasn't explicitly told us to start the game.
  """
  alias ViralSpiral.Bias
  alias ViralSpiral.Affinity
  alias ViralSpiral.Entity.Room
  alias ViralSpiral.Room.EngineConfig

  defstruct id: nil,
            name: nil,
            state: :uninitialized,
            unjoined_players: [],
            affinities: [],
            communities: [],
            chaos_counter: nil,
            chaos: nil,
            volatality: :medium

  @all_states [:reserved, :uninitialized, :waiting_for_players, :running, :paused]

  @type states :: :reserved | :uninitialized | :waiting_for_players | :running | :paused
  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          state: states(),
          unjoined_players: list(String.t()),
          affinities: list(Affinity.target()),
          communities: list(Bias.target()),
          chaos_counter: integer(),
          chaos: integer(),
          volatality: EngineConfig.volatility()
        }

  def new() do
    engine_config = %EngineConfig{}

    %Room{
      id: UXID.generate!(prefix: "room", size: :small),
      name: name(),
      state: :uninitialized,
      chaos_counter: engine_config.chaos_counter,
      chaos: engine_config.chaos_counter,
      volatality: engine_config.volatility
    }
  end

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

    %{
      room
      | id: UXID.generate!(prefix: "room", size: :small),
        state: :uninitialized,
        affinities: room_affinities,
        communities: room_communities,
        chaos_counter: engine_config.chaos_counter,
        chaos: 0,
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

  def reset_unjoined_players(%Room{} = room) do
    %{room | unjoined_players: []}
  end
end

defimpl ViralSpiral.Entity.Change, for: ViralSpiral.Entity.Room do
  alias ViralSpiral.Entity.Room

  @doc """
  Change state of a Room.
  """
  def apply_change(%Room{} = room, change_desc) do
    # change_desc = Keyword.validate!(change_desc, type: nil, offset: 0)

    case change_desc[:type] do
      :join ->
        new_player = change_desc[:player_name]
        %{room | unjoined_players: room.unjoined_players ++ [new_player]}

      :chaos_countdown ->
        Map.put(room, :chaos, room.chaos + change_desc[:offset])
    end
  end
end
