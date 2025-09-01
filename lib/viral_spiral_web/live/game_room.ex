defmodule ViralSpiralWeb.GameRoom do
  import ViralSpiralWeb.Atoms
  require IEx
  alias ViralSpiralWeb.GameRoom.StateAdapter
  alias ViralSpiral.Room.Actions
  alias ViralSpiral.Canon.Card.Sparse
  alias ViralSpiral.Room
  alias ViralSpiral.Room.Factory
  alias ViralSpiral.Entity.Player.Map, as: PlayerMap
  alias ViralSpiral.Room.Notification
  alias Phoenix.PubSub
  use ViralSpiralWeb, :live_view

  def mount(params, session, socket) do
    {:ok, assign(socket, :state, nil)}
  end

  def handle_params(%{"room" => room_name}, uri, socket) do
    pid =
      case Room.room_gen!(room_name) do
        {:ok, pid} ->
          pid

        {:error, :not_found} ->
          room_reserved = Room.reserve(room_name, :designer)
          {:ok, pid} = Room.room_gen!(room_reserved.name)
          pid
      end

    # Can be uncommented if flash notifications need to be displayed in the designer mode.

    # if connected?(socket) do
    #   PubSub.subscribe(ViralSpiral.PubSub, "multiplayer-room:#{room_name}")
    # end

    genserver_state = :sys.get_state(pid)
    # IO.inspect(genserver_state)
    room_state = StateAdapter.game_room(genserver_state)
    # assign(socket, :state, room_state)

    socket =
      socket
      |> assign(:state, room_state)
      |> assign(:change_list, [])
      |> assign(:room_gen, pid)
      |> assign(:room_name, room_name)

    {:noreply, socket}
  end

  def handle_event("start_game", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("pass_to", params, %{assigns: %{room_gen: room_gen}} = socket) do
    mapped_params = Actions.string_to_map(params)
    action = Actions.pass_card(mapped_params)
    gen_state = GenServer.call(room_gen, action)
    room_state = StateAdapter.game_room(gen_state)
    socket = socket |> assign(:state, room_state) |> maybe_put_end_banner(room_state)
    room_name = socket.assigns.room_name
    PubSub.broadcast(ViralSpiral.PubSub, "multiplayer-room:#{room_name}", {:new_action})

    notification_text =
      Notification.generate_notification(gen_state, "pass_to", normalize_params(mapped_params))

    IO.inspect({:designer_notification, "pass_to", notification_text})

    if notification_text do
      PubSub.broadcast(
        ViralSpiral.PubSub,
        "multiplayer-room:#{room_name}",
        {:notification, notification_text}
      )
    end

    {:noreply, socket}
  end

  def handle_event("keep", params, %{assigns: %{room_gen: room_gen}} = socket) do
    mapped_params = Actions.string_to_map(params)
    action = Actions.keep_card(mapped_params)
    gen_state = GenServer.call(room_gen, action)
    room_state = StateAdapter.game_room(gen_state)
    socket = assign(socket, :state, room_state)
    room_name = socket.assigns.room_name
    PubSub.broadcast(ViralSpiral.PubSub, "multiplayer-room:#{room_name}", {:new_action})

    notification_text =
      Notification.generate_notification(gen_state, "keep", normalize_params(mapped_params))

    if notification_text do
      PubSub.broadcast(
        ViralSpiral.PubSub,
        "multiplayer-room:#{room_name}",
        {:notification, notification_text}
      )
    end

    {:noreply, socket}
  end

  def handle_event("discard", params, %{assigns: %{room_gen: room_gen}} = socket) do
    mapped_params = Actions.string_to_map(params)
    action = Actions.discard_card(mapped_params)
    gen_state = GenServer.call(room_gen, action)
    room_state = StateAdapter.game_room(gen_state)
    socket = assign(socket, :state, room_state)
    room_name = socket.assigns.room_name
    PubSub.broadcast(ViralSpiral.PubSub, "multiplayer-room:#{room_name}", {:new_action})

    notification_text =
      Notification.generate_notification(gen_state, "discard", normalize_params(mapped_params))

    if notification_text do
      PubSub.broadcast(
        ViralSpiral.PubSub,
        "multiplayer-room:#{room_name}",
        {:notification, notification_text}
      )
    end

    {:noreply, socket}
  end

  def handle_event("view_source", params, %{assigns: %{room_gen: room_gen}} = socket) do
    action = Actions.view_source(params)
    gen_state = GenServer.call(room_gen, action)
    room_state = StateAdapter.game_room(gen_state)
    socket = assign(socket, :state, room_state)
    room_name = socket.assigns.room_name
    PubSub.broadcast(ViralSpiral.PubSub, "multiplayer-room:#{room_name}", {:new_action})
    {:noreply, socket}
  end

  def handle_event("hide_source", params, %{assigns: %{room_gen: room_gen}} = socket) do
    action = Actions.hide_source(params)
    gen_state = GenServer.call(room_gen, action)
    room_state = StateAdapter.game_room(gen_state)
    socket = assign(socket, :state, room_state)
    room_name = socket.assigns.room_name
    PubSub.broadcast(ViralSpiral.PubSub, "multiplayer-room:#{room_name}", {:new_action})
    {:noreply, socket}
  end

  def handle_event("mark_as_fake", params, %{assigns: %{room_gen: room_gen}} = socket) do
    action = Actions.mark_card_as_fake(Actions.string_to_map(params))
    gen_state = GenServer.call(room_gen, action)
    room_state = StateAdapter.game_room(gen_state)
    socket = assign(socket, :state, room_state)
    room_name = socket.assigns.room_name
    PubSub.broadcast(ViralSpiral.PubSub, "multiplayer-room:#{room_name}", {:new_action})
    {:noreply, socket}
  end

  def handle_event("turn_fake", params, %{assigns: %{room_gen: room_gen}} = socket) do
    action = Actions.turn_to_fake(Actions.string_to_map(params))
    gen_state = GenServer.call(room_gen, action)
    room_state = StateAdapter.game_room(gen_state)
    socket = assign(socket, :state, room_state)
    room_name = socket.assigns.room_name
    PubSub.broadcast(ViralSpiral.PubSub, "multiplayer-room:#{room_name}", {:new_action})
    {:noreply, socket}
  end

  def handle_event("initiate_cancel", params, %{assigns: %{room_gen: room_gen}} = socket) do
    mapped_params = Actions.string_to_map(params)
    action = Actions.initiate_cancel(mapped_params)
    gen_state = GenServer.call(room_gen, action)
    room_state = StateAdapter.game_room(gen_state)
    socket = assign(socket, :state, room_state)
    room_name = socket.assigns.room_name
    PubSub.broadcast(ViralSpiral.PubSub, "multiplayer-room:#{room_name}", {:new_action})

    notification_text =
      Notification.generate_notification(
        gen_state,
        "initiate_cancel",
        normalize_params(mapped_params)
      )

    if notification_text do
      PubSub.broadcast(
        ViralSpiral.PubSub,
        "multiplayer-room:#{room_name}",
        {:notification, notification_text}
      )
    end

    {:noreply, socket}
  end

  def handle_event("cancel_vote", params, %{assigns: %{room_gen: room_gen}} = socket) do
    mapped_params = Actions.string_to_map(params)
    action = Actions.vote_to_cancel(mapped_params)
    gen_state = GenServer.call(room_gen, action)
    room_state = StateAdapter.game_room(gen_state)
    socket = assign(socket, :state, room_state)
    room_name = socket.assigns.room_name
    PubSub.broadcast(ViralSpiral.PubSub, "multiplayer-room:#{room_name}", {:new_action})

    notification_text =
      Notification.generate_notification(
        gen_state,
        "cancel_vote",
        normalize_params(mapped_params)
      )

    if notification_text do
      PubSub.broadcast(
        ViralSpiral.PubSub,
        "multiplayer-room:#{room_name}",
        {:notification, notification_text}
      )
    end

    {:noreply, socket}
  end

  def handle_info({:change_reasons, message_list}, socket) do
    socket = socket |> assign(:change_list, message_list)
    {:noreply, socket}
  end

  def handle_info({:new_action}, socket) do
    %{room_gen: room_gen} = socket.assigns
    gen_state = :sys.get_state(room_gen)
    room_state = StateAdapter.game_room(gen_state)
    socket = socket |> assign(:state, room_state) |> maybe_put_end_banner(room_state)
    {:noreply, socket}
  end

  def handle_info({:notification, notification_text}, socket) do
    socket = socket |> put_flash(:info, notification_text)
    {:noreply, socket}
  end

  def player_options(state, player) do
    pass_to_ids = state.turn.pass_to

    pass_to_names =
      pass_to_ids
      |> Enum.map(&state.players[&1].name)

    pass_to_names
  end

  defp normalize_params(params) do
    %{
      "from_id" =>
        params["from_id"] || params[:from_id] || params["from"] || params[:from] ||
          params["player_id"] || params[:player_id],
      "to_id" => params["to_id"] || params[:to_id] || params["to"] || params[:to],
      "target_id" =>
        params["target_id"] || params[:target_id] || params["target"] || params[:target],
      "vote" => params["vote"] || params[:vote]
    }
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end
end
