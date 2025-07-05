defmodule ViralSpiralWeb.Utils do
  def put_banner(socket, msg) do
    alias Phoenix.LiveView
    LiveView.push_event(socket, "show_popup", %{message: msg})
  end
end
