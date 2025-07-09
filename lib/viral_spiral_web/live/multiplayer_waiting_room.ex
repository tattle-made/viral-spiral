defmodule ViralSpiralWeb.MultiplayerWaitingRoom do
  alias ViralSpiral.Room.Actions
  alias ViralSpiralWeb.MultiplayerWaitingRoom.StateAdapter
  alias ViralSpiral.Room
  use ViralSpiralWeb, :live_view
  alias Phoenix.PubSub

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-[url('/images/bg-gray.jpg')] bg-cover bg-center bg-no-repeat px-4 flex items-center justify-center">
      <div class="self-center text-center border border-4 border-[#3E6FF2] rounded-md p-8">
        <p class="text-md mb-4 text-textcolor-light text-xl font-semibold flex items-center justify-center gap-2">
          Share the
          <a class="underline text-lg text-fuchsia-900" href={"/join/#{@room_name}"}>
            Room Link
          </a>
          with other players
        </p>

        <div class="mb-16">
          <p :for={player <- @state.room.players} class="text-xl">
            <span class="text-[#C3268A] font-bold"><%= player %></span>
            <span class="text-textcolor-light"> has joined</span>
          </p>
        </div>

        <button
          class="w-full bg-fuchsia-800 hover:bg-fuchsia-500 px-4 py-2 rounded-md text-slate-50"
          phx-click="start_game"
        >
          Start Game
        </button>
      </div>
    </div>
    """
  end

  def mount(params, session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"room_name" => room_name}, uri, socket) do
    if connected?(socket) do
      PubSub.subscribe(ViralSpiral.PubSub, "waiting-room:#{room_name}")
    end

    with {:ok, pid} <- Room.room_gen!(room_name),
         game_state <- :sys.get_state(pid),
         ui_state <- StateAdapter.make_game_room(game_state, "adhiraj") do
      socket =
        socket
        |> assign(:room_name, room_name)
        |> assign(:room_gen, pid)
        |> assign(:state, ui_state)

      {:noreply, socket}
    else
      _ -> {:noreply, put_flash(socket, :error, "Unable to find room")}
    end
  end

  # todo : fix static player name
  def handle_event("start_game", _uri, %{assigns: %{room_gen: room_gen}} = socket) do
    with action <- Actions.start_game(),
         game_state <- GenServer.call(room_gen, action),
         game_state <- GenServer.call(room_gen, Actions.draw_card()),
         #  game_state <- :sys.get_state(room_gen),
         ui_state <- StateAdapter.make_game_room(game_state, "adhiraj"),
         room_name <- ui_state.room.name do
      PubSub.broadcast(ViralSpiral.PubSub, "waiting-room:#{room_name}", {:start_game})
      {:noreply, push_navigate(socket, to: "/room/#{room_name}")}
    end
  end

  def handle_info({:new_player}, %{assigns: %{room_gen: room_gen}} = socket) do
    with game_state <- :sys.get_state(room_gen),
         ui_state <- StateAdapter.make_game_room(game_state, "adhiraj") do
      {:noreply, assign(socket, :state, ui_state)}
    end
  end

  def handle_info({:start_game}, %{assigns: %{room_name: room_name}} = socket) do
    {:noreply, push_navigate(socket, to: "/room/#{room_name}")}
  end
end
