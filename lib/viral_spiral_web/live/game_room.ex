defmodule ViralSpiralWeb.GameRoom do
  import ViralSpiralWeb.Atoms
  require IEx
  alias ViralSpiral.Room.Actions
  alias ViralSpiral.Canon.Card.Sparse
  alias ViralSpiral.Room
  alias ViralSpiral.Room.Factory
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
          room_reserved = Room.reserve(room_name)
          {:ok, pid} = Room.room_gen!(room_reserved.name)
          pid
      end

    genserver_state = :sys.get_state(pid)
    # IO.inspect(genserver_state)
    room_state = Factory.make_gameroom(genserver_state)
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

  def handle_event("pass_to", params, socket) do
    action = Actions.pass_card(Actions.string_to_map(params))
    room_gen = socket.assigns.room_gen
    gen_state = GenServer.call(room_gen, action)
    room_state = Factory.make_gameroom(gen_state)

    socket = assign(socket, :state, room_state)

    {:noreply, socket}
  end

  def handle_event("keep", params, socket) do
    %{"from" => from, "card-id" => card_id, "card-veracity" => card_veracity} = params
    room_gen = socket.assigns.room_gen

    msg = {:keep, from, Sparse.new({card_id, String.to_atom(card_veracity)})}
    genserver_state = GenServer.call(room_gen, msg)

    room_state = Factory.make_gameroom(genserver_state)
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
