defmodule ViralSpiralWeb.MultiplayerRoom do
  alias ViralSpiral.Room
  alias ViralSpiralWeb.MultiplayerWaitingRoom.StateAdapter
  use ViralSpiralWeb, :live_view

  def mount(params, session, socket) do
    {:ok, socket}
  end

  def handle_params(params, uri, socket) do
    IO.inspect(params)
    IO.inspect(self())
    room_name = params["room_name"]

    {:ok, pid} = Room.room_gen!(room_name)

    socket =
      socket
      |> assign(:room_gen, pid)
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

    # socket =
    #   assign(socket, :player_name, player_name)
    #   |> assign(:state, StateAdapter.make_game_room(state))

    # {:noreply, socket}
  end

  def handle_event("healthcheck", params, socket) do
    IO.inspect(params)
    IO.inspect(socket)
    {:noreply, socket}
  end

  def handle_info({}, socket) do
  end
end
