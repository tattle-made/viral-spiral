defmodule ViralSpiralWeb.Utils do
  def put_banner(socket, msg) do
    alias Phoenix.LiveView
    LiveView.push_event(socket, "show_popup", %{message: msg})
  end

  def maybe_put_end_banner(socket, room_state) do
    case room_state.room.state do
      :over -> put_banner(socket, "todo: add Game End Message")
      _ -> socket
    end
  end
end
