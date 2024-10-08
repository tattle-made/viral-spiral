defmodule ViralSpiral.Room do
  @moduledoc """
  Context for activities within a Viral Spiral Room.

  This architecture is heavily borrowed from [here](https://dashbit.co/blog/homemade-analytics-with-ecto-and-elixir).
  Rooms in viral spiral need to manage mutable state of the game, hence they are wrapped in a `GenServer`. These genservers are then supervised by a Dynamic Supervisor, which is managed by this Supervisor. This supervisor is started by the application and is part of its supervision tree.

  ## Usage :
  ```elixir
  Room.new("vanilla-bean-23")
  engine = ViralSpiral.Room.room_gen!("ok-pista-4")
  send(engine, msg)
  ```
  """

  use Supervisor
  alias ViralSpiral.Room.NotFound

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
  @spec new(String.t()) :: no_return()
  def new(room_name) when is_binary(room_name) do
    pid =
      case Registry.lookup(@registry, room_name) do
        [{pid, _}] ->
          pid

        [] ->
          pid =
            case DynamicSupervisor.start_child(@supervisor, {@room_gen, room_name}) do
              {:ok, pid} -> pid
              {:error, {:already_started, pid}} -> pid
            end

          pid
      end

    send(pid, :new_room)
  end

  @doc """
  Returns the GenServer associated with a room name
  """
  def room_gen!(room_name) do
    case Registry.lookup(@registry, room_name) do
      [{pid, _}] -> pid
      _ -> raise NotFound
    end
  end
end

defmodule ViralSpiral.Room.NotFound do
  defexception message: "Unable to find room"
end
