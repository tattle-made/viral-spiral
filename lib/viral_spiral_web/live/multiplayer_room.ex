defmodule ViralSpiralWeb.MultiplayerRoom do
  import ViralSpiralWeb.Molecules
  alias ViralSpiral.Room.Actions
  alias ViralSpiral.Room
  alias ViralSpiral.{Affinity, Bias}
  alias ViralSpiralWeb.MultiplayerRoom.StateAdapter
  alias Phoenix.PubSub
  use ViralSpiralWeb, :live_view

  def mount(params, session, socket) do
    {:ok, socket}
  end

  def handle_params(params, uri, socket) do
    IO.inspect(params)
    IO.inspect(self())
    room_name = params["room_name"]

    if connected?(socket) do
      PubSub.subscribe(ViralSpiral.PubSub, "multiplayer-room:#{room_name}")
    end

    # {:ok, pid} = Room.room_gen!(room_name)
    pid =
      case Room.room_gen!(room_name) do
        {:ok, pid} ->
          pid

        {:error, :not_found} ->
          room_reserved = Room.reserve(room_name, :designer)
          {:ok, pid} = Room.room_gen!(room_reserved.name)
          pid
      end

    socket =
      socket
      |> assign(:room_name, room_name)
      |> assign(:room_gen, pid)
      |> assign(:state, nil)
      |> push_event("vs:mp_room:view_mounted", %{room_name: room_name})

    {:noreply, socket}
  end

  def handle_event("save_player_name_in_assigns", %{"player_name" => player_name}, socket) do
    with game_state = :sys.get_state(socket.assigns.room_gen),
         ui_state = StateAdapter.make_game_room(game_state, player_name) do
      socket =
        socket
        |> assign(:player_name, player_name)
        |> assign(:state, ui_state)

      {:noreply, socket}
    end

    # PubSub.broadcast(ViralSpiral.PubSub, "multiplayer-room:#{room_name}", {:new_action})

    # socket =
    #   assign(socket, :player_name, player_name)
    #   |> assign(:state, StateAdapter.make_game_room(state))

    # {:noreply, socket}
  end

  def handle_event("pass_to", params, socket) do
    %{room_gen: room_gen, player_name: player_name, room_name: room_name} = socket.assigns
    action = Actions.pass_card(params)
    gen_state = GenServer.call(room_gen, action)
    room_state = StateAdapter.make_game_room(gen_state, player_name)
    socket = assign(socket, :state, room_state)
    PubSub.broadcast(ViralSpiral.PubSub, "multiplayer-room:#{room_name}", {:new_action})
    {:noreply, socket}
  end

  def handle_event("keep", params, socket) do
    %{room_gen: room_gen, player_name: player_name, room_name: room_name} = socket.assigns
    action = Actions.keep_card(params)
    gen_state = GenServer.call(room_gen, action)
    room_state = StateAdapter.make_game_room(gen_state, player_name)
    socket = assign(socket, :state, room_state)
    PubSub.broadcast(ViralSpiral.PubSub, "multiplayer-room:#{room_name}", {:new_action})
    {:noreply, socket}
  end

  def handle_event("discard", params, socket) do
    %{room_gen: room_gen, player_name: player_name, room_name: room_name} = socket.assigns
    action = Actions.discard_card(params)
    gen_state = GenServer.call(room_gen, action)
    room_state = StateAdapter.make_game_room(gen_state, player_name)
    socket = assign(socket, :state, room_state)
    PubSub.broadcast(ViralSpiral.PubSub, "multiplayer-room:#{room_name}", {:new_action})
    {:noreply, socket}
  end

  def handle_event("view_source", params, socket) do
    %{room_gen: room_gen, player_name: player_name, room_name: room_name} = socket.assigns
    action = Actions.view_source(params)
    gen_state = GenServer.call(room_gen, action)
    room_state = StateAdapter.make_game_room(gen_state, player_name)
    socket = assign(socket, :state, room_state)
    PubSub.broadcast(ViralSpiral.PubSub, "multiplayer-room:#{room_name}", {:new_action})
    {:noreply, socket}
  end

  def handle_event("hide_source", params, socket) do
    %{room_gen: room_gen, player_name: player_name, room_name: room_name} = socket.assigns
    action = Actions.hide_source(params)
    gen_state = GenServer.call(room_gen, action)
    room_state = StateAdapter.make_game_room(gen_state, player_name)
    socket = assign(socket, :state, room_state)
    PubSub.broadcast(ViralSpiral.PubSub, "multiplayer-room:#{room_name}", {:new_action})
    {:noreply, socket}
  end

  def handle_event("initiate_cancel", params, socket) do
    %{room_gen: room_gen, player_name: player_name, room_name: room_name} = socket.assigns
    action = Actions.initiate_cancel(params)
    gen_state = GenServer.call(room_gen, action)
    room_state = StateAdapter.make_game_room(gen_state, player_name)
    socket = assign(socket, :state, room_state)
    PubSub.broadcast(ViralSpiral.PubSub, "multiplayer-room:#{room_name}", {:new_action})
    {:noreply, socket}
  end

  def handle_event("cancel_vote", params, socket) do
    %{room_gen: room_gen, player_name: player_name, room_name: room_name} = socket.assigns
    action = Actions.vote_to_cancel(params)
    gen_state = GenServer.call(room_gen, action)
    room_state = StateAdapter.make_game_room(gen_state, player_name)
    socket = assign(socket, :state, room_state)
    PubSub.broadcast(ViralSpiral.PubSub, "multiplayer-room:#{room_name}", {:new_action})
    {:noreply, socket}
  end

  def handle_event("healthcheck", params, socket) do
    {:noreply, socket}
  end

  def handle_info({:new_action}, socket) do
    %{room_gen: room_gen, player_name: player_name} = socket.assigns
    gen_state = :sys.get_state(room_gen)
    room_state = StateAdapter.make_game_room(gen_state, player_name)
    socket = assign(socket, :state, room_state)
    {:noreply, socket}
  end

  def handle_info({}, socket) do
    {:noreply, socket}
  end
end
