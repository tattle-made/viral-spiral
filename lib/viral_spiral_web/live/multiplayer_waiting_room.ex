defmodule ViralSpiralWeb.MultiplayerWaitingRoom do
  alias ViralSpiral.Room.Actions
  alias ElixirLS.LanguageServer.Providers.Completion.Reducer
  alias ViralSpiralWeb.MultiplayerWaitingRoom.StateAdapter
  alias ViralSpiral.Room
  use ViralSpiralWeb, :live_view
  alias Phoenix.PubSub

  def render(assigns) do
    ~H"""
    <div>
      <h1>Waiting Room</h1>
      <div>
        <p :for={player <- @state.room.players}>
          <%= "#{player} has joined" %>
        </p>
      </div>
      <button class="mt-4 bg-zinc-500 hover:bg-zinc-400 px-2 py-1" phx-click="start_game">
        Start Game
      </button>
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
      {:noreply, push_navigate(socket, to: "/multiplayer/room/#{room_name}")}
    end
  end

  def handle_info({:new_player}, %{assigns: %{room_gen: room_gen}} = socket) do
    with game_state <- :sys.get_state(room_gen),
         ui_state <- StateAdapter.make_game_room(game_state, "adhiraj") do
      {:noreply, assign(socket, :state, ui_state)}
    end
  end
end
