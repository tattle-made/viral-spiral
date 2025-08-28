defmodule ViralSpiral.Room.GameEngine do
  @moduledoc """
  A GenServer for every Room.

  All player actions are sent to this genserver, which returns or broadcasts the changes made to the game State.
  """
  require IEx
  alias ViralSpiral.Entity.ChangeMessages
  alias ViralSpiral.Room
  alias ViralSpiral.Room.State
  alias ViralSpiral.Entity.Changes
  alias ViralSpiral.Room.Actions.Player.ViralSpiralInitiate
  alias ViralSpiral.Room.Actions.Engine.OverwriteState
  alias ViralSpiral.Room.Actions.Engine.DrawCard
  alias ViralSpiral.Room.Actions.Player.StartGame
  alias ViralSpiral.Room.State.Templates.MultiplayerRoom
  alias ViralSpiral.Room.Actions.Player.ReserveRoom
  alias ViralSpiral.Room.Actions.Player.JoinRoom
  alias ViralSpiral.Room.State.Templates.Debug
  alias ViralSpiral.Room.State.Templates.DesignerRoom
  alias ViralSpiral.Room.GameSave

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
  alias ViralSpiral.Room.Reducer

  use GenServer

  @registry ViralSpiral.Room.Registry

  def start_link({room_name, room_type}) do
    GenServer.start_link(
      __MODULE__,
      {room_name, room_type},
      name: {:via, Registry, {@registry, room_name}}
    )
  end

  @impl true
  def init({room_name, room_type}) do
    case Room.get_game_save(room_name) do
      %GameSave{data: state} ->
        {:ok, state}

      nil ->
        state =
          case room_type do
            :designer -> DesignerRoom.make(room_name)
            :multiplayer -> MultiplayerRoom.make(room_name)
            :debug -> Debug.make(room_name)
          end

        room = state.room
        {:ok, _game_save} = Room.create_game_save(room.name, room.id, state, 1)
        {:ok, state}
    end
  end

  @impl true
  def handle_call(%ReserveRoom{} = action, _from, state) do
    with new_state <- Reducer.reduce(state, action),
         {:ok, _game_save} <- Room.update_game_save(new_state.room.name, new_state) do
      {:reply, new_state, new_state}
    end
  end

  @impl true
  def handle_call(%JoinRoom{} = action, _from, state) do
    with new_state <- Reducer.reduce(state, action),
         {:ok, _game_save} <- Room.update_game_save(new_state.room.name, new_state) do
      {:reply, new_state, new_state}
    end
  end

  @impl true
  def handle_call(%StartGame{} = action, _from, state) do
    with new_state <- Reducer.reduce(state, action),
         {:ok, _game_save} <- Room.update_game_save(new_state.room.name, new_state) do
      {:reply, new_state, new_state}
    end
  end

  @impl true
  def handle_call(%DrawCard{} = action, _from, state) do
    with new_state <- Reducer.reduce(state, action),
         {:ok, _game_save} <- Room.update_game_save(new_state.room.name, new_state) do
      {:reply, new_state, new_state}
    end
  end

  @impl true
  def handle_call(%PassCard{} = action, {pid, _call}, state) do
    with changes <- Changes.change(state, action),
         new_state <- Reducer.reduce(:pass_card, state, changes),
         _message_list <- send(pid, {:change_reasons, ChangeMessages.message_string(changes)}),
         {:ok, _game_save} <- Room.update_game_save(new_state.room.name, new_state) do
      {:reply, new_state, new_state}
    end
  end

  @impl true
  def handle_call(%KeepCard{} = action, {pid, _call}, state) do
    with changes <- Changes.change(state, action),
         change_messages <- ChangeMessages.message_string(changes),
         new_state <- Reducer.reduce(:keep_card, state, changes),
         _change_messages <- send(pid, {:change_reasons, change_messages}),
         {:ok, _game_save} <- Room.update_game_save(new_state.room.name, new_state) do
      {:reply, new_state, new_state}
    end
  end

  @impl true
  def handle_call(%DiscardCard{} = action, {pid, _call}, state) do
    with changes <- Changes.change(state, action),
         change_messages <- ChangeMessages.message_string(changes),
         new_state <- Reducer.reduce(:discard_card, state, changes),
         _change_messages <- send(pid, {:change_reasons, change_messages}),
         {:ok, _game_save} <- Room.update_game_save(new_state.room.name, new_state) do
      {:reply, new_state, new_state}
    end
  end

  @impl true
  def handle_call(%ViewSource{} = action, _from, state) do
    with new_state <- Reducer.reduce(state, action),
         {:ok, _game_save} <- Room.update_game_save(new_state.room.name, new_state) do
      {:reply, new_state, new_state}
    end
  end

  @impl true
  def handle_call(%HideSource{} = action, _from, state) do
    with new_state <- Reducer.reduce(state, action),
         {:ok, _game_save} <- Room.update_game_save(new_state.room.name, new_state) do
      {:reply, new_state, new_state}
    end
  end

  @impl true
  def handle_call(%TurnToFake{} = action, _from, state) do
    with new_state <- Reducer.reduce(state, action),
         {:ok, _game_save} <- Room.update_game_save(new_state.room.name, new_state) do
      {:reply, new_state, new_state}
    end
  end

  @impl true
  def handle_call(%MarkAsFake{} = action, _from, state) do
    with new_state <- Reducer.reduce(state, action),
         {:ok, _game_save} <- Room.update_game_save(new_state.room.name, new_state) do
      {:reply, new_state, new_state}
    end
  end

  @impl true
  def handle_call(%CancelPlayerInitiate{} = action, _from, state) do
    with new_state <- Reducer.reduce(state, action),
         {:ok, _game_save} <- Room.update_game_save(new_state.room.name, new_state) do
      {:reply, new_state, new_state}
    end
  end

  @impl true
  def handle_call(%CancelPlayerVote{} = action, _from, state) do
    with new_state <- Reducer.reduce(state, action),
         {:ok, _game_save} <- Room.update_game_save(new_state.room.name, new_state) do
      {:reply, new_state, new_state}
    end
  end

  @impl true
  def handle_call(%ViralSpiralInitiate{} = action, _from, state) do
    with new_state <- Reducer.reduce(state, action),
         {:ok, _game_save} <- Room.update_game_save(new_state.room.name, new_state) do
      {:reply, new_state, new_state}
    end
  end

  def handle_call(%OverwriteState{} = action, from, state) do
    new_state = action.new_state
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
