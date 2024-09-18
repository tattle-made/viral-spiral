defmodule ViralSpiralWeb.WaitingRoom do
  @moduledoc """
  A space for people to wait while other players join.

  We enforce that atleast 3 players are present before someone can start the game.
  """
  use ViralSpiralWeb, :live_view

  def mount(params, session, socket) do
    {:ok, socket}
  end

  def handle_event("start_game", _params, socket) do
    {:noreply, socket}
  end
end
