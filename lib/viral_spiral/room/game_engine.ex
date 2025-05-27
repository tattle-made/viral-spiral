defmodule ViralSpiral.Room.GameEngine do
  @moduledoc """
  A GenServer for every Room.

  All player actions are sent to this genserver, which returns or broadcasts the changes made to the game State.
  """
  alias ViralSpiral.Room.Actions.Player.CancelPlayerVote
  alias ViralSpiral.Room.Actions.Player.CancelPlayerInitiate
  alias ViralSpiral.Room.Actions.Player.MarkAsFake
  alias ViralSpiral.Room.Actions.Player.TurnToFake
  alias ViralSpiral.Room.Actions.Player.HideSource
  alias ViralSpiral.Room.Actions.Player.ViewSource
  alias ViralSpiral.Room.Actions.Player.DiscardCard
  alias ViralSpiral.Room.Actions.Player.KeepCard
  alias ViralSpiral.Room.Actions.Player.PassCard
  alias ViralSpiral.Room.Actions
  alias ViralSpiral.Room.Reducer
  alias ViralSpiral.Canon.Card.Sparse
  alias ViralSpiral.Room.Factory
  alias ViralSpiral.Room.State
  alias ViralSpiral.Entity.Room
  use GenServer

  @registry ViralSpiral.Room.Registry

  def start_link(room_name) do
    GenServer.start_link(__MODULE__, room_name, name: {:via, Registry, {@registry, room_name}})
  end

  @impl true
  def init(room_name) do
    state =
      State.skeleton(room_name: room_name)
      |> Reducer.reduce(Actions.reserve_room(%{player_name: "adhiraj"}))
      |> Reducer.reduce(Actions.join_room(%{player_name: "aman"}))
      |> Reducer.reduce(Actions.join_room(%{player_name: "farah"}))
      |> Reducer.reduce(Actions.join_room(%{player_name: "krys"}))
      |> Reducer.reduce(Actions.start_game())
      |> Reducer.reduce(Actions.draw_card())

    {:ok, state}
  end

  @impl true
  def handle_cast({:start}, state) do
  end

  @impl true
  def handle_cast({:join, player_name}, state) do
  end

  @impl true
  def handle_call(%PassCard{} = action, _from, state) do
    new_state = Reducer.reduce(state, action)
    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call(%KeepCard{} = action, _from, state) do
    new_state = Reducer.reduce(state, action)
    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call(%DiscardCard{} = action, _from, state) do
    new_state = Reducer.reduce(state, action)
    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call(%ViewSource{} = action, _from, state) do
    new_state = Reducer.reduce(state, action)
    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call(%HideSource{} = action, _from, state) do
    new_state = Reducer.reduce(state, action)
    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call(%TurnToFake{} = action, _from, state) do
    new_state = Reducer.reduce(state, action)
    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call(%MarkAsFake{} = action, _from, state) do
    new_state = Reducer.reduce(state, action)
    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call(%CancelPlayerInitiate{} = action, _from, state) do
    new_state = Reducer.reduce(state, action)
    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call(%CancelPlayerVote{} = action, _from, state) do
    new_state = Reducer.reduce(state, action)
    {:reply, new_state, new_state}
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
