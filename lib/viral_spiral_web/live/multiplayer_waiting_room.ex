defmodule ViralSpiralWeb.MultiplayerWaitingRoom do
  alias ViralSpiral.Room.Actions
  alias ViralSpiralWeb.MultiplayerWaitingRoom.StateAdapter
  alias ViralSpiral.Room
  use ViralSpiralWeb, :live_view
  alias Phoenix.PubSub
  import ViralSpiralWeb.Molecules

  def render(assigns) do
    ~H"""
    <div class="relative min-h-screen bg-[url('/images/bg-gray.jpg')] bg-cover bg-center bg-no-repeat px-4 flex items-center justify-center">
      <div class="absolute top-0 right-2">
        <button phx-click={show_modal("rulebook")} class="text-fuchsia-900 hover:text-fuchsia-700">
          <span class="text-sm font-bold">Rulebook</span> <.icon name="hero-book-open-solid" />
        </button>
        <.rulebook />
      </div>
      <div class="self-center text-center border-4 border-[#3E6FF2] rounded-md p-8">
        <p class="text-md mb-4 text-textcolor-light text-xl font-semibold flex items-center justify-center gap-2">
          Share the Room Link with other players
          <div
            id="room-link-copy-clipboard-container"
            class="w-full"
            phx-hook="RoomLinkCopyClipboardHook"
          >
            <div class="relative">
              <input
                id="display-join-link"
                type="text"
                class="col-span-6 bg-gray-50 border border-gray-300 text-gray-500 text-sm rounded-lg block w-full p-2.5 "
                value={"#{@full_host}/join/#{@room_name}"}
                disabled
                readonly
              />
              <button
                data-copy-to-clipboard-target="display-join-link"
                data-tooltip-target="tooltip-copy-display-join-link"
                class="absolute end-2 top-1/2 -translate-y-1/2  hover:bg-gray-100 rounded-lg p-2 inline-flex items-center justify-center"
              >
                <span id="default-icon">
                  📋
                </span>
                <span id="success-icon" class="hidden">
                  <svg
                    class="w-3.5 h-3.5 text-blue-500"
                    aria-hidden="true"
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 16 12"
                  >
                    <path
                      stroke="currentColor"
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M1 5.917 5.724 10.5 15 1.5"
                    />
                  </svg>
                </span>
              </button>
              <div
                id="tooltip-copy-display-join-link"
                role="tooltip"
                class="absolute z-10 invisible inline-block px-3 py-2 text-sm font-medium text-white transition-opacity duration-300 bg-gray-900 rounded-lg shadow-xs opacity-0 tooltip "
              >
                <span id="default-tooltip-message">Copy to clipboard</span>
                <span id="success-tooltip-message" class="hidden">Copied!</span>
                <div class="tooltip-arrow" data-popper-arrow></div>
              </div>
            </div>
          </div>
        </p>

        <div class="mb-16 mt-4">
          <p :for={player <- @state.room.players} class="text-xl">
            <span class="text-[#C3268A] font-bold"><%= player %></span>
            <span class="text-textcolor-light"> has joined</span>
          </p>
        </div>

        <button
          class={"w-full bg-fuchsia-800 hover:bg-fuchsia-500 px-4 py-2 rounded-md text-slate-50 plausible-event-name=Start+Game plausible-event-room=#{@room_name}"}
          phx-click="start_game"
        >
          Start Game
        </button>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"room_name" => room_name}, uri, socket) do
    %URI{host: host, scheme: scheme, port: port} = URI.parse(uri)

    port_part =
      case {scheme, port} do
        {"https", 443} -> ""
        {"http", 80} -> ""
        _ -> ":#{port}"
      end

    full_host = "#{scheme}://#{host}#{port_part}"

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
        |> assign(:full_host, full_host)

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
