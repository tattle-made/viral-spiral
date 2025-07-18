defmodule ViralSpiralWeb.Multiplayer do
  require IEx
  alias ViralSpiral.Room.Actions.Player.ReserveRoom
  alias ViralSpiral.Room.State
  alias Phoenix.PubSub
  alias ViralSpiral.Room.Actions
  alias ViralSpiral.Room
  alias ViralSpiral.Entity.Room, as: EntityRoom
  use ViralSpiralWeb, :live_view

  @rules [
    "On each turn, a player draws a card. This card represents a news article found somewhere on the internet - this could be either FACTUAL news, a strong OPINION about a harmless topic, or a misinformation expressing PREJUDICE against one of the in-game communities the players are randomly sorted into.",
    "On their turn, a player can choose to check the source of their card, then either pass it to another player, discard it, or keep it in their hand for later. For every new player a card is passed to, the original sharer gets 1 CLOUT point.",
    "Sharing OPINION or PREJUDICE cards add to a player’s OPINION or PREJUDICE counters - this means that in subsequent turns, they’ll need to compulsorily share cards that align with that opinion, or lose 1 clout as a penalty for going against their confirmation bias.",
    "Sharing prejudice cards also counts towards the global CHAOS counter. Counting down from 10, once it reaches 0, the game ends and every player loses instantly.",
    "Crossing certain thresholds in your opinion or prejudice counters unlock certain powers - having +2 or -2 opinion lets you CANCEL other players, if you can get players with the same opinion as you to vote it into play. +/-3 prejudice lets you MANUFACTURE fake news, by adding prejudice to any card you might have in your hand.",
    "Crossing +/-5 on any opinion or prejudice unlocks the VIRAL SPIRAL power - that lets you share 1 unique card from your hand to every player in the same turn - often a game-changing, game-ending move.",
    "The first player to reach 10 CLOUT without letting CHAOS hit 0, wins!"
  ]

  def mount(_params, _session, socket) do
    form = to_form(%{"player_name" => ""})
    join_room_form = to_form(%{"room_name" => "", "player_name" => ""})

    socket =
      socket
      |> assign(:form, form)
      |> assign(:join_room_form, join_room_form)
      |> assign(:show_create_form, false)
      |> assign(:show_join_form, false)
      |> assign(:rules, @rules)

    {:ok, socket}
  end

  # New event handlers for toggling panels
  def handle_event("toggle_create_panel", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_create_form, !socket.assigns.show_create_form)
     # Close join form when create is opened
     |> assign(:show_join_form, false)}
  end

  def handle_event("toggle_join_panel", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_join_form, !socket.assigns.show_join_form)
     # Close create form when join is opened
     |> assign(:show_create_form, false)}
  end

  def handle_event("stop_propagation", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("create_new_room", params, socket) do
    room_name = EntityRoom.name()
    IO.inspect(params, label: "PARAMS ARE: ")
    action = Actions.reserve_room(params)

    with %{name: reserved_room_name} <- Room.reserve(room_name, :multiplayer),
         {:ok, room_gen} <- Room.room_gen!(reserved_room_name),
         %State{} <- GenServer.call(room_gen, action) do
      path = "/room/waiting-room/#{reserved_room_name}"
      query_string = URI.encode_query(socket.assigns[:params] || %{})

      socket =
        socket
        |> push_event("vs:mp_room:create_room", %{
          room_name: room_name,
          player_name: action.player_name
        })
        |> push_navigate(to: proxy_path(socket, path) <> query_string)

      {:noreply, socket}
    else
      err ->
        IO.inspect(err)
        {:noreply, put_flash(socket, :error, "Could not create a new room")}
    end
  end

  def handle_event("join_room", params, socket) do
    IO.inspect(params)
    room_name = params["room_name"]
    player_name = params["player_name"]
    query_string = URI.encode_query(socket.assigns[:params] || %{})

    with {:ok, room_gen} <- Room.room_gen!(room_name),
         _state <- GenServer.call(room_gen, Actions.join_room(%{player_name: player_name})),
         path <- "/room/waiting-room/#{room_name}" do
      PubSub.broadcast(ViralSpiral.PubSub, "waiting-room:#{room_name}", {:new_player})

      socket =
        socket
        |> push_event("vs:mp_room:join_room", %{room_name: room_name, player_name: player_name})
        |> push_navigate(to: proxy_path(socket, path) <> query_string)

      {:noreply, socket}
    else
      err ->
        IO.inspect(err, label: "error is here")
        {:noreply, put_flash(socket, :error, "Could not join room")}
    end
  end
end
