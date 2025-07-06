defmodule ViralSpiralWeb.MultiplayerJoinRoom do
  alias ViralSpiral.Room.Actions
  alias ViralSpiral.Room
  alias Phoenix.PubSub
  use ViralSpiralWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="h-full justify-center flex">
      <div class="w-80 border-green-100 border-2 p-4 rounded-md self-center">
        <.simple_form for={@form} phx-submit="join_room">
          <.input field={@form[:room_name]} label="Room Name" />
          <.input field={@form[:player_name]} id="player_name_join" label="Username" />
          <:actions>
            <.button class="w-full bg-fuchsia-800 hover:bg-fuchsia-500">Join Room</.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  def mount(params, session, socket) do
    {:ok, socket}
  end

  def handle_params(unsigned_params, uri, socket) do
    form = to_form(%{"room_name" => unsigned_params["room_name"], "player_name" => ""})
    socket = socket |> assign(:form, form)
    {:noreply, socket}
  end

  def handle_event("join_room", params, socket) do
    IO.inspect(params)
    # todo fix : room_name is not available. is it because its disabled in the form?
    room_name = params["room_name"]
    player_name = params["player_name"]

    with {:ok, room_gen} <- Room.room_gen!(room_name),
         _state <- GenServer.call(room_gen, Actions.join_room(%{player_name: player_name})),
         path <- "/room/waiting-room/" <> params["room_name"] do
      PubSub.broadcast(ViralSpiral.PubSub, "waiting-room:#{room_name}", {:new_player})

      socket =
        socket
        |> push_event("vs:mp_room:join_room", %{room_name: room_name, player_name: player_name})
        |> push_navigate(to: path)

      {:noreply, socket}
    else
      err ->
        IO.inspect(err, label: "error is here")
        {:noreply, put_flash(socket, :error, "Could not join room")}
    end
  end
end
