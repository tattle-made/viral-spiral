defmodule ViralSpiral.Entity.Room do
  @moduledoc """
  Room specific configuration for every game.

  ## Room States
  - :reserved : When a player has expressed an interest to play the game but their friends haven't joined the room yet or the player hasn't explicitly told us to start the game.

  chaos starts at 0 and goes up. Max value is 10 for now.
  state
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
            volatality: :medium,
            cancel_threshold: 0,
            turn_fake_threshold: 0,
            viral_spiral_threshold: 0

  @states [:uninitialized, :reserved, :waiting_for_players, :running, :paused]

  @type states :: :reserved | :uninitialized | :waiting_for_players | :running | :paused | :over
  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          state: states(),
          unjoined_players: list(String.t()),
          affinities: list(Affinity.target()),
          communities: list(Bias.target()),
          chaos_counter: integer(),
          volatality: EngineConfig.volatility(),
          cancel_threshold: integer(),
          turn_fake_threshold: integer(),
          viral_spiral_threshold: integer()
        }

  def new() do
    engine_config = %EngineConfig{}
    uxid = Application.get_env(:viral_spiral, :uxid)

    %Room{
      id: uxid.generate!(prefix: "room", size: :small),
      name: name(),
      state: :uninitialized,
      chaos_counter: engine_config.chaos_counter,
      volatality: engine_config.volatility,
      cancel_threshold: engine_config.cancel_threshold,
      turn_fake_threshold: engine_config.turn_fake_threshold,
      viral_spiral_threshold: engine_config.viral_spiral_threshold
    }
  end

  @doc """
  Create a Room with fields that don't require user input.
  """
  def skeleton(opts \\ []) do
    room_name = Keyword.get(opts, :room_name, name())

    engine_config = %EngineConfig{}
    uxid = Application.get_env(:viral_spiral, :uxid)

    %Room{
      id: uxid.generate!(prefix: "room", size: :small),
      name: room_name,
      state: :uninitialized,
      chaos_counter: engine_config.chaos_counter,
      chaos: 0,
      volatality: engine_config.volatility,
      cancel_threshold: engine_config.cancel_threshold,
      turn_fake_threshold: engine_config.turn_fake_threshold,
      viral_spiral_threshold: engine_config.viral_spiral_threshold
    }
  end

  def can_reserve?(%Room{} = room) do
    is_uninitialized = room.state == :uninitialized
    no_other_players = length(room.unjoined_players) == 0

    is_uninitialized && no_other_players
  end

  @doc """
  Reserve a room.

  A player can reserve a room, share its URL with their friends and wait for them to join the room.
  """
  @spec reserve(String.t()) :: Room.t()
  def reserve(name) when is_bitstring(name) do
    uxid = Application.get_env(:viral_spiral, :uxid)

    %Room{
      id: uxid.generate!(prefix: "room", size: :small),
      name: name,
      state: :reserved
    }
  end

  def start(%Room{} = room) do
    player_count = length(room.unjoined_players)

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
      | state: :running,
        affinities: room_affinities,
        communities: room_communities,
        chaos_counter: engine_config.chaos_counter,
        chaos: 0,
        volatality: engine_config.volatility
    }
  end

  def set_state(%Room{} = room, state) when state in @states do
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

    Enum.random(adjectives) <>
      "-" <>
      Enum.random(nouns) <>
      "-" <> for(_ <- 1..5, into: "", do: <<Enum.random(~c"0123456789abcdef")>>)
  end

  def join(%Room{} = room, player_name) do
    %{room | unjoined_players: room.unjoined_players ++ [player_name]}
  end

  def reset_unjoined_players(%Room{} = room) do
    %{room | unjoined_players: []}
  end

  defimpl ViralSpiral.Entity.Change do
    @moduledoc """
    Change properties of a Room
    """
    alias ViralSpiral.Entity.Room.Changes.EndGame
    alias ViralSpiral.Entity.Room.Changes.OffsetChaos
    alias ViralSpiral.Entity.Room.Changes.OffsetCountdown
    alias ViralSpiral.Entity.Room.Exceptions.JoinBeforeReserving
    alias ViralSpiral.Entity.Room.Exceptions.IllegalReservation
    alias ViralSpiral.Entity.Change.UndefinedChange

    alias ViralSpiral.Entity.Room.Changes.{
      ReserveRoom,
      JoinRoom,
      StartGame,
      ChangeCountdown,
      ResetUnjoinedPlayers
    }

    alias ViralSpiral.Entity.Room

    @type change_types ::
            ReserveRoom.t()
            | JoinRoom.t()
            | StartGame.t()
            | ChangeCountdown.t()
            | ResetUnjoinedPlayers.t()

    @spec change(Room.t(), change_types()) :: Room.t()
    def change(%Room{} = room, %ReserveRoom{} = change) do
      case Room.can_reserve?(room) do
        true -> Room.join(room, change.player_name) |> Room.set_state(:reserved)
        false -> raise IllegalReservation, message: "You can not reserve this room"
      end
    end

    def change(%Room{} = room, %JoinRoom{} = change) do
      case room.state in [:reserved, :waiting_for_players] do
        true ->
          Room.join(room, change.player_name)
          |> Room.set_state(:waiting_for_players)

        false ->
          raise JoinBeforeReserving
      end
    end

    def change(%Room{} = room, %StartGame{} = _change) do
      room |> Room.start()
    end

    def change(%Room{} = room, %OffsetChaos{} = change) do
      Map.put(room, :chaos, room.chaos + change.offset)
    end

    def change(%Room{} = room, %ResetUnjoinedPlayers{} = _change) do
      Room.reset_unjoined_players(room)
    end

    def change(%Room{} = room, %EndGame{reason: reason} = _change) do
      case reason do
        nil -> room
        _ -> %{room | state: :over}
      end
    end

    def change(%Room{} = _room, _change) do
      raise UndefinedChange, message: "You are trying to make an unsupported change to this Room"
    end
  end
end
