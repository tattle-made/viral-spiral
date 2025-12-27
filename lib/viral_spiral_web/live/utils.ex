defmodule ViralSpiralWeb.Utils do
  def put_banner(socket, msg) do
    alias Phoenix.LiveView
    LiveView.push_event(socket, "show_popup", %{message: msg})
  end

  def send_endgame_metric(socket, room_name) do
    alias Phoenix.LiveView
    LiveView.push_event(socket, "send_endgame_metric", %{room: room_name})
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

  def maybe_send_endgame_metric(socket, room_state) do
    room_name = room_state.room.name

    case room_state.room.state do
      :over ->
        send_endgame_metric(socket, room_name)

      _ ->
        socket
    end
  end
end
