defmodule ViralSpiralWeb.GameRoomChannel do
  use Phoenix.Channel
  alias ViralSpiral.Room
  alias ViralSpiral.Room.Actions
  alias ViralSpiral.Room.Notification
  alias ViralSpiralWeb.GameRoomChannel.StateAdapter
  alias Phoenix.PubSub

  def join("game_room:" <> room_name, %{"player_name" => player_name}, socket) do
    with {:ok, room_gen} <- Room.room_gen!(room_name),
         game_state <- :sys.get_state(room_gen) do
      PubSub.subscribe(ViralSpiral.PubSub, "multiplayer-room:#{room_name}")
      socket = socket
        |> assign(:room_name, room_name)
        |> assign(:player_name, player_name)
        |> assign(:room_gen, room_gen)
      ui_state = StateAdapter.make_game_room(game_state, player_name)
      {:ok, ui_state, socket}
    else
      _ -> {:error, %{reason: "Room not found"}}
    end
  end

  # pass_to: %{"from_id" => id, "to_id" => id, "card" => %{"id" => id, "veracity" => bool}}
  def handle_in("pass_to", params, socket) do
    %{room_gen: room_gen, player_name: player_name, room_name: room_name} = socket.assigns
    action = Actions.pass_card(params)
    gen_state = GenServer.call(room_gen, action)
    notification_text = Notification.generate_notification(gen_state, "pass_to", params)
    broadcast_state(room_name, gen_state, notification_text)
    ui_state = StateAdapter.make_game_room(gen_state, player_name)
    {:reply, {:ok, ui_state}, socket}
  end

  def handle_in("keep", params, socket) do
    %{room_gen: room_gen, player_name: player_name, room_name: room_name} = socket.assigns
    action = Actions.keep_card(params)
    gen_state = GenServer.call(room_gen, action)
    notification_text = Notification.generate_notification(gen_state, "keep", params)
    broadcast_state(room_name, gen_state, notification_text)
    ui_state = StateAdapter.make_game_room(gen_state, player_name)
    {:reply, {:ok, ui_state}, socket}
  end

  def handle_in("discard", params, socket) do
    %{room_gen: room_gen, player_name: player_name, room_name: room_name} = socket.assigns
    action = Actions.discard_card(params)
    gen_state = GenServer.call(room_gen, action)
    notification_text = Notification.generate_notification(gen_state, "discard", params)
    broadcast_state(room_name, gen_state, notification_text)
    ui_state = StateAdapter.make_game_room(gen_state, player_name)
    {:reply, {:ok, ui_state}, socket}
  end

  def handle_in("view_source", params, socket) do
    %{room_gen: room_gen, player_name: player_name, room_name: room_name} = socket.assigns
    action = Actions.view_source(params)
    gen_state = GenServer.call(room_gen, action)
    broadcast_state(room_name, gen_state, nil)
    ui_state = StateAdapter.make_game_room(gen_state, player_name)
    {:reply, {:ok, ui_state}, socket}
  end

  def handle_in("hide_source", params, socket) do
    %{room_gen: room_gen, player_name: player_name, room_name: room_name} = socket.assigns
    action = Actions.hide_source(params)
    gen_state = GenServer.call(room_gen, action)
    broadcast_state(room_name, gen_state, nil)
    ui_state = StateAdapter.make_game_room(gen_state, player_name)
    {:reply, {:ok, ui_state}, socket}
  end

  def handle_in("mark_as_fake", params, socket) do
    %{room_gen: room_gen, player_name: player_name, room_name: room_name} = socket.assigns
    action = Actions.mark_card_as_fake(params)
    gen_state = GenServer.call(room_gen, action)
    broadcast_state(room_name, gen_state, nil)
    ui_state = StateAdapter.make_game_room(gen_state, player_name)
    {:reply, {:ok, ui_state}, socket}
  end

  def handle_in("turn_fake", params, socket) do
    %{room_gen: room_gen, player_name: player_name, room_name: room_name} = socket.assigns
    action = Actions.turn_to_fake(params)
    gen_state = GenServer.call(room_gen, action)
    broadcast_state(room_name, gen_state, nil)
    ui_state = StateAdapter.make_game_room(gen_state, player_name)
    {:reply, {:ok, ui_state}, socket}
  end

  def handle_in("initiate_cancel", params, socket) do
    %{room_gen: room_gen, player_name: player_name, room_name: room_name} = socket.assigns
    action = Actions.initiate_cancel(params)
    gen_state = GenServer.call(room_gen, action)
    notification_text = Notification.generate_notification(gen_state, "initiate_cancel", params)
    broadcast_state(room_name, gen_state, notification_text)
    ui_state = StateAdapter.make_game_room(gen_state, player_name)
    {:reply, {:ok, ui_state}, socket}
  end

  def handle_in("cancel_vote", params, socket) do
    %{room_gen: room_gen, player_name: player_name, room_name: room_name} = socket.assigns
    action = Actions.vote_to_cancel(params)
    gen_state = GenServer.call(room_gen, action)
    notification_text = Notification.generate_notification(gen_state, "cancel_vote", params)
    broadcast_state(room_name, gen_state, notification_text)
    ui_state = StateAdapter.make_game_room(gen_state, player_name)
    {:reply, {:ok, ui_state}, socket}
  end

  def handle_in("initiate_viral_spiral", params, socket) do
    %{room_gen: room_gen, player_name: player_name, room_name: room_name} = socket.assigns
    action = Actions.initiate_viralspiral(params)
    gen_state = GenServer.call(room_gen, action)
    notification_text = Notification.generate_notification(gen_state, "initiate_viral_spiral", params)
    broadcast_state(room_name, gen_state, notification_text)
    ui_state = StateAdapter.make_game_room(gen_state, player_name)
    {:reply, {:ok, ui_state}, socket}
  end

  # Receive PubSub broadcast, push personalized state to this client
  def handle_info({:new_action}, socket) do
    %{room_gen: room_gen, player_name: player_name} = socket.assigns
    gen_state = :sys.get_state(room_gen)
    ui_state = StateAdapter.make_game_room(gen_state, player_name)
    push(socket, "state_update", ui_state)
    {:noreply, socket}
  end

  def handle_info({:notification, nil}, socket), do: {:noreply, socket}
  def handle_info({:notification, text}, socket) do
    push(socket, "notification", %{text: text})
    {:noreply, socket}
  end

  def handle_info({:change_reasons, reasons}, socket) do
    push(socket, "change_reasons", %{reasons: reasons})
    {:noreply, socket}
  end

  def handle_info({:display_reasons, reasons}, socket) do
    push(socket, "change_reasons", %{reasons: reasons})
    {:noreply, socket}
  end

  def handle_info(_, socket), do: {:noreply, socket}

  defp broadcast_state(room_name, _gen_state, notification_text) do
    PubSub.broadcast(ViralSpiral.PubSub, "multiplayer-room:#{room_name}", {:new_action})
    if notification_text do
      PubSub.broadcast(ViralSpiral.PubSub, "multiplayer-room:#{room_name}", {:notification, notification_text})
    end
  end
end
