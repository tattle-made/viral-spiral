defmodule ViralSpiralWeb.GameRoom do
  import ViralSpiralWeb.Atoms
  require IEx
  alias ViralSpiralWeb.GameRoom.StateAdapter
  alias ViralSpiral.Room.Actions
  alias ViralSpiral.Canon.Card.Sparse
  alias ViralSpiral.Room
  alias ViralSpiral.Room.Factory
  alias ViralSpiral.Entity.Player.Map, as: PlayerMap
  use ViralSpiralWeb, :live_view

  def mount(params, session, socket) do
    {:ok, assign(socket, :state, nil)}
  end

  def handle_params(%{"room" => room_name}, uri, socket) do
    pid =
      case Room.room_gen!(room_name) do
        {:ok, pid} ->
          pid

        {:error, :not_found} ->
          room_reserved = Room.reserve(room_name, :designer)
          {:ok, pid} = Room.room_gen!(room_reserved.name)
          pid
      end

    IO.inspect("hi")

    genserver_state = :sys.get_state(pid)
    # IO.inspect(genserver_state)
    room_state = StateAdapter.game_room(genserver_state)
    # assign(socket, :state, room_state)

    socket =
      socket
      |> assign(:state, room_state)
      |> assign(:room_gen, pid)

    {:noreply, socket}
  end

  def handle_event("start_game", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("pass_to", params, %{assigns: %{room_gen: room_gen}} = socket) do
    action = Actions.pass_card(Actions.string_to_map(params))
    gen_state = GenServer.call(room_gen, action)
    room_state = StateAdapter.game_room(gen_state)
    socket = socket |> assign(:state, room_state) |> maybe_put_end_banner(room_state)
    {:noreply, socket}
  end

  def handle_event("keep", params, %{assigns: %{room_gen: room_gen}} = socket) do
    action = Actions.keep_card(Actions.string_to_map(params))
    gen_state = GenServer.call(room_gen, action)
    room_state = StateAdapter.game_room(gen_state)
    socket = assign(socket, :state, room_state)
    {:noreply, socket}
  end

  def handle_event("discard", params, %{assigns: %{room_gen: room_gen}} = socket) do
    action = Actions.discard_card(Actions.string_to_map(params))
    gen_state = GenServer.call(room_gen, action)
    room_state = StateAdapter.game_room(gen_state)
    socket = assign(socket, :state, room_state)
    {:noreply, socket}
  end

  def handle_event("view_source", params, %{assigns: %{room_gen: room_gen}} = socket) do
    action = Actions.view_source(params)
    gen_state = GenServer.call(room_gen, action)
    room_state = StateAdapter.game_room(gen_state)
    socket = assign(socket, :state, room_state)
    {:noreply, socket}
  end

  def handle_event("hide_source", params, %{assigns: %{room_gen: room_gen}} = socket) do
    action = Actions.hide_source(params)
    gen_state = GenServer.call(room_gen, action)
    room_state = StateAdapter.game_room(gen_state)
    socket = assign(socket, :state, room_state)
    {:noreply, socket}
  end

  def handle_event("mark_as_fake", params, %{assigns: %{room_gen: room_gen}} = socket) do
    action = Actions.mark_card_as_fake(Actions.string_to_map(params))
    gen_state = GenServer.call(room_gen, action)
    room_state = StateAdapter.game_room(gen_state)
    socket = assign(socket, :state, room_state)
    {:noreply, socket}
  end

  def handle_event("turn_fake", params, %{assigns: %{room_gen: room_gen}} = socket) do
    action = Actions.turn_to_fake(Actions.string_to_map(params))
    gen_state = GenServer.call(room_gen, action)
    room_state = StateAdapter.game_room(gen_state)
    socket = assign(socket, :state, room_state)
    {:noreply, socket}
  end

  def handle_event("initiate_cancel", params, %{assigns: %{room_gen: room_gen}} = socket) do
    action = Actions.initiate_cancel(params)
    gen_state = GenServer.call(room_gen, action)
    room_state = StateAdapter.game_room(gen_state)
    socket = assign(socket, :state, room_state)
    {:noreply, socket}
  end

  def handle_event("cancel_vote", params, %{assigns: %{room_gen: room_gen}} = socket) do
    action = Actions.vote_to_cancel(Actions.string_to_map(params))
    gen_state = GenServer.call(room_gen, action)
    room_state = StateAdapter.game_room(gen_state)
    socket = assign(socket, :state, room_state)
    {:noreply, socket}
  end

  def player_options(state, player) do
    pass_to_ids = state.turn.pass_to

    pass_to_names =
      pass_to_ids
      |> Enum.map(&state.players[&1].name)

    pass_to_names
  end
end
