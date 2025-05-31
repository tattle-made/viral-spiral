defmodule ViralSpiral.Room.GameEngine do
  @moduledoc """
  A GenServer for every Room.

  All player actions are sent to this genserver, which returns or broadcasts the changes made to the game State.
  """
  require IEx
  alias ViralSpiral.Room.GameSave
  alias ViralSpiral.Room
  alias ViralSpiral.Room.StateTransformation
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
  alias ViralSpiral.Room.State

  use GenServer

  @registry ViralSpiral.Room.Registry

  def start_link(room_name) do
    GenServer.start_link(__MODULE__, room_name, name: {:via, Registry, {@registry, room_name}})
  end

  @impl true
  def init(room_name) do
    # state =
    #   case Room.get_game_save(room_name) do
    #     nil ->
    #       State.skeleton(room_name: room_name)
    #       |> Reducer.reduce(Actions.reserve_room(%{player_name: "adhiraj"}))
    #       |> Reducer.reduce(Actions.join_room(%{player_name: "aman"}))
    #       |> Reducer.reduce(Actions.join_room(%{player_name: "farah"}))
    #       |> Reducer.reduce(Actions.join_room(%{player_name: "krys"}))
    #       |> Reducer.reduce(Actions.start_game())
    #       |> Reducer.reduce(Actions.draw_card())

    #     %GameSave{data: data} ->
    #       data
    #   end

    # todo : only for debugging
    # players = StateTransformation.player_id_by_names(state)
    # %{adhiraj: adhiraj, aman: aman, farah: farah, krys: krys} = players

    # sparse_card = StateTransformation.draw_card(state, {:affinity, true, :sock})

    # state =
    #   state
    #   |> StateTransformation.update_player(adhiraj, %{affinities: %{sock: 5, skub: 0}})
    #   |> StateTransformation.update_player(aman, %{affinities: %{sock: 2, skub: 0}})
    #   |> StateTransformation.update_player(farah, %{affinities: %{sock: 2, skub: 0}})
    #   |> StateTransformation.update_player(krys, %{affinities: %{sock: -1, skub: 4}})
    #   |> StateTransformation.update_round(%{order: [adhiraj, aman, krys, farah]})
    #   |> StateTransformation.update_turn(%{current: adhiraj, pass_to: [aman, krys, farah]})
    #   |> StateTransformation.update_player(adhiraj, %{active_cards: [sparse_card]})

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

defmodule ViralSpiral.Room.GameEngine.Exceptions do
  defmodule CouldNotReserveRoom do
    defexception message: "Could not reserve room"
  end
end
