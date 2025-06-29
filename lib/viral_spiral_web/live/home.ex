defmodule ViralSpiralWeb.Home do
  alias ViralSpiral.Room
  alias ViralSpiral.Entity.Room, as: EntityRoom
  import ViralSpiralWeb.Atoms
  use ViralSpiralWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:count, 12)
      |> assign(:image_id, 0)

    {:ok, socket}
  end

  def handle_event("create_room", _params, socket) do
    room_name = EntityRoom.name()

    _pid =
      case Room.room_gen!(room_name) do
        {:ok, pid} ->
          pid

        {:error, :not_found} ->
          room_reserved = Room.reserve(room_name, :designer)
          {:ok, pid} = Room.room_gen!(room_reserved.name)
          pid
      end

    # {:noreply, push_navigate(socket, to: "/waiting-room/#{name}")}
    {:noreply, push_navigate(socket, to: "/room/#{room_name}")}
  end

  def handle_event("increment_counter", _params, socket) do
    new_count = socket.assigns.count + 1
    socket = socket |> assign(:count, new_count)

    {:noreply, socket}
  end

  def handle_event("change_background", _params, socket) do
    new_image_id = rem(socket.assigns.image_id + 1, 5)
    socket = socket |> assign(:image_id, new_image_id)

    IO.inspect(new_image_id)

    {:noreply, socket}
  end
end
