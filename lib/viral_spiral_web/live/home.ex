defmodule ViralSpiralWeb.Home do
  alias ViralSpiral.Room.State.Room
  use ViralSpiralWeb, :live_view

  def mount(params, session, socket) do
    {:ok, socket}
  end

  def handle_event("create_room", _params, socket) do
    name = Room.name()
    # {:noreply, push_navigate(socket, to: "/waiting-room/#{name}")}
    {:noreply, push_navigate(socket, to: "/room/#{name}")}
  end
end
