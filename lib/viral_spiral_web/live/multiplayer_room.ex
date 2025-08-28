defmodule ViralSpiralWeb.MultiplayerRoom do
  import ViralSpiralWeb.Molecules
  alias ViralSpiral.S3
  alias ViralSpiralWeb.Atoms
  alias ViralSpiral.Room.Actions
  alias ViralSpiral.Room
  alias ViralSpiral.{Affinity, Bias}
  alias ViralSpiralWeb.MultiplayerRoom.StateAdapter
  alias ViralSpiral.Room.Notification
  alias Phoenix.PubSub
  use ViralSpiralWeb, :live_view

  def mount(params, session, socket) do
    {:ok, socket}
  end

  def handle_params(params, uri, socket) do
    IO.inspect(params)
    IO.inspect(self())
    room_name = params["room_name"]

    if connected?(socket) do
      PubSub.subscribe(ViralSpiral.PubSub, "multiplayer-room:#{room_name}")
    end

    # {:ok, pid} = Room.room_gen!(room_name)
    pid =
      case Room.room_gen!(room_name) do
        {:ok, pid} ->
          pid

        {:error, :not_found} ->
          room_reserved = Room.reserve(room_name, :designer)
          {:ok, pid} = Room.room_gen!(room_reserved.name)
          pid
      end

    socket =
      socket
      |> assign(:room_name, room_name)
      |> assign(:room_gen, pid)
      |> assign(:state, nil)
      |> assign(:change_list, [])
      |> push_event("vs:mp_room:view_mounted", %{room_name: room_name})

    {:noreply, socket}
  end

  def handle_event("save_player_name_in_assigns", %{"player_name" => player_name}, socket) do
    with game_state = :sys.get_state(socket.assigns.room_gen),
         ui_state = StateAdapter.make_game_room(game_state, player_name) do
      socket =
        socket
        |> assign(:player_name, player_name)
        |> assign(:state, ui_state)

      {:noreply, socket}
    end

    # PubSub.broadcast(ViralSpiral.PubSub, "multiplayer-room:#{room_name}", {:new_action})

    # socket =
    #   assign(socket, :player_name, player_name)
    #   |> assign(:state, StateAdapter.make_game_room(state))

    # {:noreply, socket}
  end

  def handle_event("pass_to", params, socket) do
    %{room_gen: room_gen, player_name: player_name, room_name: room_name} = socket.assigns
    action = Actions.pass_card(params)
    gen_state = GenServer.call(room_gen, action)
    room_state = StateAdapter.make_game_room(gen_state, player_name)
    notification_text = Notification.generate_notification(gen_state, "pass_to", params)
    socket = socket |> assign(:state, room_state) |> maybe_put_end_banner(room_state)
    PubSub.broadcast(ViralSpiral.PubSub, "multiplayer-room:#{room_name}", {:new_action})

    PubSub.broadcast(
      ViralSpiral.PubSub,
      "multiplayer-room:#{room_name}",
      {:notification, notification_text}
    )

    {:noreply, socket}
  end

  def handle_event("keep", params, socket) do
    %{room_gen: room_gen, player_name: player_name, room_name: room_name} = socket.assigns
    action = Actions.keep_card(params)
    gen_state = GenServer.call(room_gen, action)
    room_state = StateAdapter.make_game_room(gen_state, player_name)
    notification_text = Notification.generate_notification(gen_state, "keep", params)
    socket = socket |> assign(:state, room_state)
    PubSub.broadcast(ViralSpiral.PubSub, "multiplayer-room:#{room_name}", {:new_action})

    PubSub.broadcast(
      ViralSpiral.PubSub,
      "multiplayer-room:#{room_name}",
      {:notification, notification_text}
    )

    {:noreply, socket}
  end

  def handle_event("discard", params, socket) do
    %{room_gen: room_gen, player_name: player_name, room_name: room_name} = socket.assigns
    action = Actions.discard_card(params)
    gen_state = GenServer.call(room_gen, action)
    room_state = StateAdapter.make_game_room(gen_state, player_name)
    notification_text = Notification.generate_notification(gen_state, "discard", params)
    socket = socket |> assign(:state, room_state)
    PubSub.broadcast(ViralSpiral.PubSub, "multiplayer-room:#{room_name}", {:new_action})

    PubSub.broadcast(
      ViralSpiral.PubSub,
      "multiplayer-room:#{room_name}",
      {:notification, notification_text}
    )

    {:noreply, socket}
  end

  def handle_event("view_source", params, socket) do
    %{room_gen: room_gen, player_name: player_name, room_name: room_name} = socket.assigns
    action = Actions.view_source(params)
    gen_state = GenServer.call(room_gen, action)
    room_state = StateAdapter.make_game_room(gen_state, player_name)
    socket = socket |> assign(:state, room_state)
    PubSub.broadcast(ViralSpiral.PubSub, "multiplayer-room:#{room_name}", {:new_action})
    {:noreply, socket}
  end

  def handle_event("hide_source", params, socket) do
    %{room_gen: room_gen, player_name: player_name, room_name: room_name} = socket.assigns
    action = Actions.hide_source(params)
    gen_state = GenServer.call(room_gen, action)
    room_state = StateAdapter.make_game_room(gen_state, player_name)
    socket = socket |> assign(:state, room_state)
    PubSub.broadcast(ViralSpiral.PubSub, "multiplayer-room:#{room_name}", {:new_action})
    {:noreply, socket}
  end

  def handle_event("mark_as_fake", params, %{assigns: %{room_gen: room_gen}} = socket) do
    %{room_gen: room_gen, player_name: player_name, room_name: room_name} = socket.assigns
    action = Actions.mark_card_as_fake(params)
    gen_state = GenServer.call(room_gen, action)
    room_state = StateAdapter.make_game_room(gen_state, player_name)
    socket = socket |> assign(:state, room_state)
    PubSub.broadcast(ViralSpiral.PubSub, "multiplayer-room:#{room_name}", {:new_action})
    {:noreply, socket}
  end

  def handle_event("turn_fake", params, %{assigns: %{room_gen: room_gen}} = socket) do
    %{room_gen: room_gen, player_name: player_name, room_name: room_name} = socket.assigns
    action = Actions.turn_to_fake(params)
    gen_state = GenServer.call(room_gen, action)
    room_state = StateAdapter.make_game_room(gen_state, player_name)
    socket = socket |> assign(:state, room_state)
    PubSub.broadcast(ViralSpiral.PubSub, "multiplayer-room:#{room_name}", {:new_action})
    {:noreply, socket}
  end

  def handle_event("initiate_cancel", params, socket) do
    %{room_gen: room_gen, player_name: player_name, room_name: room_name} = socket.assigns
    action = Actions.initiate_cancel(params)
    gen_state = GenServer.call(room_gen, action)
    room_state = StateAdapter.make_game_room(gen_state, player_name)
    notification_text = Notification.generate_notification(gen_state, "initiate_cancel", params)
    socket = socket |> assign(:state, room_state)
    PubSub.broadcast(ViralSpiral.PubSub, "multiplayer-room:#{room_name}", {:new_action})

    PubSub.broadcast(
      ViralSpiral.PubSub,
      "multiplayer-room:#{room_name}",
      {:notification, notification_text}
    )

    {:noreply, socket}
  end

  def handle_event("cancel_vote", params, socket) do
    %{room_gen: room_gen, player_name: player_name, room_name: room_name} = socket.assigns
    action = Actions.vote_to_cancel(params)
    gen_state = GenServer.call(room_gen, action)
    room_state = StateAdapter.make_game_room(gen_state, player_name)
    notification_text = Notification.generate_notification(gen_state, "cancel_vote", params)
    socket = socket |> assign(:state, room_state)
    PubSub.broadcast(ViralSpiral.PubSub, "multiplayer-room:#{room_name}", {:new_action})

    PubSub.broadcast(
      ViralSpiral.PubSub,
      "multiplayer-room:#{room_name}",
      {:notification, notification_text}
    )

    {:noreply, socket}
  end

  def handle_event("initiate_viral_spiral", params, socket) do
    %{room_gen: room_gen, player_name: player_name, room_name: room_name} = socket.assigns
    action = Actions.initiate_viralspiral(params)
    gen_state = GenServer.call(room_gen, action)
    room_state = StateAdapter.make_game_room(gen_state, player_name)

    notification_text =
      Notification.generate_notification(gen_state, "initiate_viral_spiral", params)

    socket = socket |> assign(:state, room_state)
    PubSub.broadcast(ViralSpiral.PubSub, "multiplayer-room:#{room_name}", {:new_action})

    PubSub.broadcast(
      ViralSpiral.PubSub,
      "multiplayer-room:#{room_name}",
      {:notification, notification_text}
    )

    {:noreply, socket}
  end

  def handle_event("healthcheck", params, socket) do
    {:noreply, socket}
  end

  def handle_info({:new_action}, socket) do
    %{room_gen: room_gen, player_name: player_name} = socket.assigns
    gen_state = :sys.get_state(room_gen)
    room_state = StateAdapter.make_game_room(gen_state, player_name)
    socket = socket |> assign(:state, room_state) |> maybe_put_end_banner(room_state)
    {:noreply, socket}
  end

  def handle_info({:notification, notification_text}, socket) do
    socket = socket |> put_flash(:info, notification_text)
    {:noreply, socket}
  end

  def handle_info({:change_reasons, message_list}, socket) do
    socket = socket |> assign(:change_list, message_list)
    {:noreply, socket}
  end

  def handle_info({}, socket) do
    {:noreply, socket}
  end

  def bg_image(chaos) do
    case chaos do
      nil -> S3.bg("bg_0.png")
      x when x >= 0 and x <= 2 -> S3.bg("bg_0.png")
      x when x > 2 and x <= 4 -> S3.bg("bg_1.png")
      x when x > 4 and x <= 6 -> S3.bg("bg_2.png")
      x when x > 6 and x <= 8 -> S3.bg("bg_3.png")
      x when x > 8 and x <= 10 -> S3.bg("bg_4.png")
      _ -> S3.bg("bg_0.png")
    end
  end
end
