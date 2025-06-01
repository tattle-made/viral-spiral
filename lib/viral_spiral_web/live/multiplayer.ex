defmodule ViralSpiralWeb.Multiplayer do
  require IEx
  alias Phoenix.PubSub
  alias ViralSpiral.Room.Actions
  alias ViralSpiral.Room
  alias ViralSpiral.Entity.Room, as: EntityRoom
  use ViralSpiralWeb, :live_view

  def render(assigns) do
    ~H"""
    <h1>Multiplayer Room</h1>
    <div class="flex flex-row gap-12 flex-wrap">
      <div class="w-80 border-orange-100 border-2 p-4 rounded-md">
        <.simple_form for={@form} phx-submit="create_new_room">
          <.input field={@form[:player_name]} label="Username" />
          <:actions>
            <.button class="w-full">Create a new Room</.button>
          </:actions>
        </.simple_form>
      </div>

      <div class="w-80 border-green-100 border-2 p-4 rounded-md">
        <.simple_form for={@form} phx-submit="join_room">
          <.input field={@form[:room_name]} label="Room Name" />
          <.input field={@form[:player_name]} label="Username" />
          <:actions>
            <.button class="w-full">Join Room</.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    form = to_form(%{"player_name" => ""})
    join_room_form = to_form(%{"room_name" => "", "player_name" => ""})

    socket =
      socket
      |> assign(:form, form)
      |> assign(:join_room_form, join_room_form)

    {:ok, socket}
  end

  def handle_event("create_new_room", params, socket) do
    room_name = EntityRoom.name()

    with %{name: reserved_room_name} <- Room.reserve(room_name, :multiplayer),
         {:ok, room_gen} <- Room.room_gen!(reserved_room_name),
         :ok <- GenServer.call(room_gen, Actions.reserve_room(params)) do
      {:noreply,
       push_navigate(socket, to: "/multiplayer/room/waiting-room/#{reserved_room_name}")}
    else
      _ ->
        {:noreply, put_flash(socket, :error, "Could not create a new room")}
    end
  end

  def handle_event("join_room", params, socket) do
    IO.inspect(params)
    room_name = params["room_name"]
    player_name = params["player_name"]

    with {:ok, room_gen} <- Room.room_gen!(room_name),
         :ok <- GenServer.call(room_gen, Actions.join_room(%{player_name: player_name})),
         path <- "/multiplayer/room/waiting-room/" <> params["room_name"] do
      PubSub.broadcast(ViralSpiral.PubSub, "waiting-room:#{room_name}", {:new_player})
      {:noreply, push_navigate(socket, to: path)}
    else
      _ -> {:noreply, put_flash(socket, :error, "Could not join room")}
    end
  end
end
