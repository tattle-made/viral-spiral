defmodule ViralSpiral.Room.GameEngine do
  @moduledoc """
  A GenServer for every Room.

  All player actions are sent to this genserver, which returns or broadcasts the changes made to the game State.
  """
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
  def handle_call(%{type: :pass_card} = action, _from, state) do
    new_state = Reducer.reduce(state, action)
    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call({:keep, from, %Sparse{} = card}, _from, state) do
    new_state =
      state
      |> Factory.keep_card(card, from)
      |> Factory.draw_card()

    {:reply, new_state, new_state}
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
