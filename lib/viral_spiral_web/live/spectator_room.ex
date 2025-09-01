defmodule ViralSpiralWeb.SpectatorRoom do
  import ViralSpiralWeb.Molecules
  alias ViralSpiral.S3
  alias ViralSpiralWeb.Atoms
  alias ViralSpiral.Room
  alias ViralSpiralWeb.SpectatorRoom.StateAdapter
  alias Phoenix.PubSub
  use ViralSpiralWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
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

    game_state = :sys.get_state(pid)
    ui_state = StateAdapter.make_spectator_room(game_state)

    socket =
      socket
      |> assign(:room_name, room_name)
      |> assign(:room_gen, pid)
      |> assign(:state, ui_state)
      |> maybe_put_end_banner(ui_state)

    {:noreply, socket}
  end

  def handle_event("healthcheck", _params, socket) do
    {:noreply, socket}
  end

  # Spectator mode - ignore all game action events
  def handle_event("view_source", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("hide_source", _params, socket) do
    # IO.puts("hide_source in spectator")
    {:noreply, socket}
  end

  def handle_info({:new_action}, socket) do
    %{room_gen: room_gen} = socket.assigns
    gen_state = :sys.get_state(room_gen)
    room_state = StateAdapter.make_spectator_room(gen_state)
    socket = socket |> assign(:state, room_state) |> maybe_put_end_banner(room_state)
    {:noreply, socket}
  end

  def handle_info({:notification, notification_text}, socket) do
    socket = socket |> put_flash(:info, notification_text)
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
