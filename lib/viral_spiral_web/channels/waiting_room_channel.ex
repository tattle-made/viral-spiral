defmodule ViralSpiralWeb.WaitingRoomChannel do
  use Phoenix.Channel
  alias ViralSpiral.Room
  alias ViralSpiral.Room.Actions
  alias Phoenix.PubSub

  def join("waiting_room:" <> room_name, %{"player_name" => player_name}, socket) do
    with {:ok, room_gen} <- Room.room_gen!(room_name) do
      game_state = :sys.get_state(room_gen)
      # Creator was already added via reserve_room; only call join_room for new players
      unless player_name in game_state.room.unjoined_players do
        GenServer.call(room_gen, Actions.join_room(%{player_name: player_name}))
      end
      PubSub.subscribe(ViralSpiral.PubSub, "waiting-room:#{room_name}")
      PubSub.broadcast(ViralSpiral.PubSub, "waiting-room:#{room_name}", {:new_player})
      socket = socket
        |> assign(:room_name, room_name)
        |> assign(:player_name, player_name)
        |> assign(:room_gen, room_gen)
      players = (:sys.get_state(room_gen)).room.unjoined_players
      {:ok, %{players: players}, socket}
    else
      _ -> {:error, %{reason: "Could not join room"}}
    end
  end

  def join("waiting_room:" <> room_name, _params, socket) do
    # Rejoin without player_name (spectator/already joined)
    with {:ok, room_gen} <- Room.room_gen!(room_name),
         game_state <- :sys.get_state(room_gen) do
      PubSub.subscribe(ViralSpiral.PubSub, "waiting-room:#{room_name}")
      socket = socket
        |> assign(:room_name, room_name)
        |> assign(:room_gen, room_gen)
      players = Map.values(game_state.players) |> Enum.map(& &1.name)
      {:ok, %{players: players}, socket}
    else
      _ -> {:error, %{reason: "Room not found"}}
    end
  end

  def handle_in("start_game", _params, socket) do
    %{room_gen: room_gen, room_name: room_name} = socket.assigns
    GenServer.call(room_gen, Actions.start_game())
    GenServer.call(room_gen, Actions.draw_card())
    PubSub.broadcast(ViralSpiral.PubSub, "waiting-room:#{room_name}", {:start_game})
    {:reply, :ok, socket}
  end

  def handle_info({:new_player}, socket) do
    %{room_gen: room_gen} = socket.assigns
    game_state = :sys.get_state(room_gen)
    players = game_state.room.unjoined_players
    push(socket, "state_update", %{players: players})
    {:noreply, socket}
  end

  def handle_info({:start_game}, socket) do
    push(socket, "start_game", %{})
    {:noreply, socket}
  end
end
