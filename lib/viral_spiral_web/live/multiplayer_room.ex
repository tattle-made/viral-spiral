defmodule ViralSpiralWeb.MultiplayerRoom do
  alias ViralSpiralWeb.GameRoom.StateAdapter
  alias ViralSpiral.Room.State.Templates.Debug
  use ViralSpiralWeb, :live_view

  def mount(params, session, socket) do
    # state = Debug.make("keen-apple-32323")

    ui_state = %{
      "room" => %{
        id: "asdfadf-asf",
        name: "keen-apple-3232"
      },
      "others" => [
        %{
          id: "asdf-323-23",
          name: "adhiraj",
          affinities: [%{type: "Sock", count: 2}, %{type: "Houseboat", count: 5}]
        },
        %{
          id: "pepq-323-23",
          name: "aman",
          affinities: [%{type: "Sock", count: 6}, %{type: "Houseboat", count: 9}]
        }
      ],
      "me" => %{
        id: "ndcq-323-23",
        name: "farah",
        affinities: [%{type: "Sock", count: 1}, %{type: "Houseboat", count: 2}]
      }
    }

    socket = socket |> assign(:state, ui_state)
    {:ok, socket}
  end

  def handle_event("test", unsigned_params, socket) do
    # IO.inspect("clicked")
    # msg = socket.assigns.state.msg
    # socket = socket |> assign(:state, %{msg: msg <> "lalala"})
    {:noreply, socket}
  end
end
