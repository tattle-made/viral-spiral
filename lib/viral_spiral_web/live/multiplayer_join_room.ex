defmodule ViralSpiralWeb.MultiplayerJoinRoom do
  alias ViralSpiral.Room.Actions
  alias ViralSpiral.Room
  alias Phoenix.PubSub
  use ViralSpiralWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-[url('/images/bg-gray.jpg')] bg-cover bg-center bg-no-repeat px-4 flex items-center justify-center">
      <div class="w-full max-w-md text-center border border-4 border-[#3E6FF2] rounded-md p-8 bg-transparent">
        <h2 class="text-2xl font-semibold text-textcolor-light mb-6">
          Join a Room
        </h2>

        <.simple_form_home for={@form} phx-submit="join_room">
          <.input field={@form[:room_name]} label="Room Name" />
          <.input field={@form[:player_name]} id="player_name_join" label="Username" />
          <:actions>
            <.button class="w-full mt-4 bg-fuchsia-800 hover:bg-fuchsia-500 text-slate-50 px-4 py-2 rounded-md">
              Join Room
            </.button>
          </:actions>
        </.simple_form_home>
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
