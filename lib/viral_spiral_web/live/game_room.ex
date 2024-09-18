defmodule ViralSpiralWeb.GameRoom do
  alias ViralSpiral.Room.State.Room
  alias ViralSpiral.Room.State.Root
  use ViralSpiralWeb, :live_view

  def mount(params, session, socket) do
    room =
      Room.new()
      |> Room.start(4)

    root = Root.new(room, ["adhiraj", "krys", "aman", "farah"])
    IO.inspect(root)
    IO.puts("hi")

    {:ok, assign(socket, :root, root)}
  end

  def handle_event("start_game", _params, socket) do
    {:noreply, socket}
  end
end
