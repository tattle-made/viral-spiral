defmodule ViralSpiral.GameTest do
  @moduledoc """
  A step by step recreation of every step of a game.

  We only do 2 rounds for brevity.
  """
  alias ViralSpiral.Entity.PlayerMap
  alias ViralSpiral.Room.Factory
  alias ViralSpiral.Entity.Player
  alias ViralSpiral.Entity.Turn
  alias ViralSpiral.Entity.Round
  alias ViralSpiral.Room.State
  alias ViralSpiral.Entity.Room
  alias ViralSpiral.Game
  use ExUnit.Case

  test "Play a round" do
    :rand.seed(:exsss, {1, 87, 90})

    # Player One creates a room and gets its link to share with others
    room = Room.new()
    assert room.chaos_counter != nil
    assert room.id != nil
    assert room.state == :uninitialized
    assert room.name != nil
    assert room.name == "basic-venus"

    # Start a game with 4 Players
    room = Room.start(room, 4)
    assert room.affinities != []
    assert room.communities != []
    assert room.state == :running

    root = State.new(room, ["adhiraj", "krys", "aman", "farah"])
    assert match?(%State{players: %{}, round: %Round{}, turn: %Turn{}}, root)

    round = root.round
    turn = root.turn

    player_a = Enum.at(round.order, 0)
    player_b = Enum.at(round.order, 1)
    player_c = Enum.at(round.order, 2)
    player_d = Enum.at(round.order, 3)

    # draw a card and pass it and check state at every point
    assert match?(
             %State{
               players: %{
                 ^player_a => %Player{clout: 0},
                 ^player_b => %Player{clout: 0, biases: %{yellow: 0}}
               }
             },
             root
           )
  end

  @tag timeout: :infinity
  test "happy path" do
    :rand.seed(:exsss, {123, 135, 254})
    alias ViralSpiral.Canon.Card.Sparse

    state =
      Factory.new_game()
      |> Factory.join("adhiraj")
      |> Factory.join("aman")
      |> Factory.join("farah")
      |> Factory.join("krys")
      |> Factory.start()
      |> Factory.draw_card()

    # %{adhiraj: adhiraj, aman: aman, farah: farah, krys: krys} =
    #   StateFixtures.player_by_names(state)
    [player_a, player_b, player_c, player_d] = state.round.order
    current_player = State.current_turn_player(state)

    # player_a = state.players[player_a]
    # player_b = state.players[player_b]
    # player_c = state.players[player_c]
    # player_d = state.players[player_d]

    # assert current_player.id == player_a

    current_card = StateFixtures.active_card(state, current_player.id, 0)

    state =
      state
      |> Factory.pass_card(current_card, player_a, player_d)
      |> Factory.pass_card(current_card, player_d, player_b)

    # assert state.players[player_a].clout == 2
    # assert state.players[player_a].affinities.skub == -1
    # assert state.players[player_d].affinities.skub == -1

    state =
      state
      |> Factory.keep_card(current_card, player_b)
      |> Factory.draw_card()

    current_card = StateFixtures.active_card(state, player_b, 0) |> IO.inspect()

    state = state |> Factory.discard_card(current_card, player_b)

    # state
    # |> Factory.pass_card(current_card,)

    # IO.inspect(current_card)

    # |> Factory.pass_card()
    # |> then(fn state ->
    #   IO.inspect(state.players)
    #   IO.inspect(state.room)
    # end)
  end
end
