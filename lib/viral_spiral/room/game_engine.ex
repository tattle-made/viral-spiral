defmodule ViralSpiral.Room.GameEngine do
  @moduledoc """
  A GenServer for every Room.

  All player actions are sent to this genserver, which returns or broadcasts the changes made to the game State.
  """
  alias ViralSpiral.Room.State
  alias ViralSpiral.Entity.Room
  use GenServer

  @registry ViralSpiral.Room.Registry

  def start_link(room_name) do
    GenServer.start_link(__MODULE__, room_name, name: {:via, Registry, {@registry, room_name}})
  end

  @impl true
  def init(name) do
    room = Room.reserve(name) |> Room.start(4)
    state = State.new(room, ["adhiraj", "krys", "aman", "farah"])

    {:ok, state}
  end

  @impl true
  def handle_cast({:start}, state) do
  end

  @impl true
  def handle_cast({:join, player_name}, state) do
  end

  @impl true
  def handle_cast({:pass, from, to}, state) do
  end

  @impl true
  def handle_cast({:keep, from}, state) do
  end

  @impl true
  def handle_cast({:discard, from}, state) do
  end

  @impl true
  def handle_cast({:check_source, from}, state) do
  end

  @impl true
  def handle_cast({:cancel, from, target}, state) do
  end

  @impl true
  def handle_cast({:viral_spiral, from, targets}, state) do
  end

  @impl true
  def handle_info(msg, state) do
    IO.inspect("msg in genserver #{msg}")
    {:noreply, state}
  end
end

defmodule ViralSpiral.Room.GameEngine.RoomReserved do
  defstruct name: nil

  @type t :: %__MODULE__{
          name: String.t()
        }
end
