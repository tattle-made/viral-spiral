defmodule ViralSpiralWeb.Utils do
  def put_banner(socket, msg) do
    alias Phoenix.LiveView
    LiveView.push_event(socket, "show_popup", %{message: msg})
  end

  def maybe_put_end_banner(socket, room_state) do
    case room_state.room.state do
      :over ->
        if is_binary(room_state.end_game_message) do
          put_banner(socket, room_state.end_game_message)
        else
          put_banner(socket, "Game over")
        end

      _ ->
        socket
    end
  end
end
