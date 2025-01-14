defmodule ViralSpiralWeb.GameRoom do
  import ViralSpiralWeb.Atoms
  alias ViralSpiral.Canon.Card.Sparse
  alias ViralSpiral.Canon.Card
  alias ViralSpiral.Entity.Player
  alias ViralSpiral.Canon.Deck
  alias ViralSpiral.Room.Factory
  alias ViralSpiral.Room.Actions
  alias ViralSpiral.Room.Reducer
  alias ViralSpiral.Room.State
  alias ViralSpiral.Entity.Room
  use ViralSpiralWeb, :live_view

  def mount(params, session, socket) do
    room = Room.new() |> Room.start(4)
    state = State.new(room, ["adhiraj", "krys", "aman", "farah"])
    requirements = Factory.draw_type(state)
    draw_type = Deck.draw_type(requirements)
    state = Reducer.reduce(state, Actions.draw_card(draw_type))

    gameroom_state = Factory.make_gameroom(state)

    IO.inspect("hello")

    {:ok, assign(socket, :state, gameroom_state)}
  end

  def handle_event("start_game", _params, socket) do
    {:noreply, socket}
  end

  def handle_event(
        "pass_to",
        params,
        socket
      ) do
    %{"from" => from, "to" => to, "card-id" => card_id, "card-veracity" => card_veracity} = params
    state = socket.assigns.state

    state =
      state |> Factory.pass_card(Sparse.new({card_id, String.to_atom(card_veracity)}), from, to)

    {:noreply, assign(socket, :state, state)}
  end

  def player_options(state, player) do
    pass_to_ids = state.turn.pass_to

    pass_to_names =
      pass_to_ids
      |> Enum.map(&state.players[&1].name)

    pass_to_names
  end
end
