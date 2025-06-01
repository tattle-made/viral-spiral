defmodule ViralSpiralWeb.Home do
  alias ViralSpiral.Room
  alias ViralSpiral.Entity.Room, as: EntityRoom
  use ViralSpiralWeb, :live_view

  def mount(_params, _session, socket) do
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
end
