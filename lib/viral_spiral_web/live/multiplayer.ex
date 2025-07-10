defmodule ViralSpiralWeb.Multiplayer do
  require IEx
  alias ViralSpiral.Room.Actions.Player.ReserveRoom
  alias ViralSpiral.Room.State
  alias Phoenix.PubSub
  alias ViralSpiral.Room.Actions
  alias ViralSpiral.Room
  alias ViralSpiral.Entity.Room, as: EntityRoom
  use ViralSpiralWeb, :live_view

  def mount(_params, _session, socket) do
    form = to_form(%{"player_name" => ""})
    join_room_form = to_form(%{"room_name" => "", "player_name" => ""})

    socket =
      socket
      |> assign(:form, form)
      |> assign(:join_room_form, join_room_form)
      |> assign(:show_create_form, false)
      |> assign(:show_join_form, false)

    {:ok, socket}
  end

  # New event handlers for toggling panels
  def handle_event("toggle_create_panel", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_create_form, !socket.assigns.show_create_form)
     # Close join form when create is opened
     |> assign(:show_join_form, false)}
  end

  def handle_event("toggle_join_panel", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_join_form, !socket.assigns.show_join_form)
     # Close create form when join is opened
     |> assign(:show_create_form, false)}
  end

  def handle_event("stop_propagation", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("create_new_room", params, socket) do
    room_name = EntityRoom.name()
    action = Actions.reserve_room(params)

    with %{name: reserved_room_name} <- Room.reserve(room_name, :multiplayer),
         {:ok, room_gen} <- Room.room_gen!(reserved_room_name),
         %State{} <- GenServer.call(room_gen, action) do
      path = "/room/waiting-room/#{reserved_room_name}"

      socket =
        socket
        |> push_event("vs:mp_room:create_room", %{
          room_name: room_name,
          player_name: action.player_name
        })
        |> push_navigate(to: path)

      {:noreply, socket}
    else
      err ->
        IO.inspect(err)
        {:noreply, put_flash(socket, :error, "Could not create a new room")}
    end
  end

  def handle_event("join_room", params, socket) do
    IO.inspect(params)
    room_name = params["room_name"]
    player_name = params["player_name"]

    with {:ok, room_gen} <- Room.room_gen!(room_name),
         _state <- GenServer.call(room_gen, Actions.join_room(%{player_name: player_name})),
         path <- "/room/waiting-room/#{room_name}" do
      PubSub.broadcast(ViralSpiral.PubSub, "waiting-room:#{room_name}", {:new_player})

      socket =
        socket
        |> push_event("vs:mp_room:join_room", %{room_name: room_name, player_name: player_name})
        |> push_navigate(to: path)

      {:noreply, socket}
    else
      err ->
        IO.inspect(err, label: "error is here")
        {:noreply, put_flash(socket, :error, "Could not join room")}
    end
  end
end
