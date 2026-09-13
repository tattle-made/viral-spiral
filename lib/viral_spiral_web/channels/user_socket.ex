defmodule ViralSpiralWeb.UserSocket do
  use Phoenix.Socket

  channel "waiting_room:*", ViralSpiralWeb.WaitingRoomChannel
  channel "game_room:*", ViralSpiralWeb.GameRoomChannel

  @impl true
  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  @impl true
  def id(_socket), do: nil
end
