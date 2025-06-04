defmodule ViralSpiral.Room do
  @moduledoc """
  Context for activities within a Viral Spiral Room.

  This architecture is heavily borrowed from [here](https://dashbit.co/blog/homemade-analytics-with-ecto-and-elixir).
  Rooms in viral spiral need to manage mutable state of the game, hence they are wrapped in a `GenServer`. These genservers are then supervised by a Dynamic Supervisor, which is managed by this Supervisor. This supervisor is started by the application and is part of its supervision tree.

  ## Usage :
  ```elixir
  room_reserved = Room.reserve()
  {:ok, room_gen} = Room.room_gen!(room_reserved.name)
  send(room_gen, "ok")
  :sys.get_state(room_gen)
  ```
  """

  use Supervisor
  alias ViralSpiral.Repo
  alias ViralSpiral.Room.GameSave
  alias ViralSpiral.Room.GameEngine.Exceptions.CouldNotReserveRoom
  alias ViralSpiral.Room.GameEngine.RoomReserved

  @room_gen ViralSpiral.Room.GameEngine
  @registry ViralSpiral.Room.Registry
  @supervisor ViralSpiral.Room.GameEngineSupervisor

  @doc """
  Used by `Application`
  """
  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    children = [
      {Registry, keys: :unique, name: @registry},
      {DynamicSupervisor, name: @supervisor, strategy: :one_for_one}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end

  @doc """
  Registers and creates a new Room.

  This ensures there is only one room registered with a path.
  """
  @spec reserve(String.t(), atom()) :: RoomReserved.t()
  def reserve(room_name, room_type) do
    _pid =
      case DynamicSupervisor.start_child(@supervisor, {@room_gen, {room_name, room_type}}) do
        {:ok, pid} ->
          pid

        {:error, {:already_started, pid}} ->
          pid

        _ ->
          raise CouldNotReserveRoom
      end

    # send(pid, :new_room)
    %RoomReserved{name: room_name}
  end

  @doc """
  Returns the GenServer associated with a room name
  """
  def room_gen!(room_name) do
    case Registry.lookup(@registry, room_name) do
      [{pid, _}] -> {:ok, pid}
      _ -> {:error, :not_found}
    end
  end

  def create_game_save(room_name, room_id, data, version) do
    %GameSave{}
    |> GameSave.changeset(%{room_name: room_name, room_id: room_id, data: data, version: version})
    |> Repo.insert()
  end

  def update_game_save(room_name, data) do
    get_game_save(room_name)
    |> GameSave.changeset_update_data(%{data: data})
    |> Repo.update()
  end

  def get_game_save(room_name) do
    Repo.get_by(GameSave, room_name: room_name)
  end
end

defmodule ViralSpiral.Room.NotFound do
  defexception message: "Unable to find room"
end
