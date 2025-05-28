defmodule ViralSpiral.GameTest do
  @moduledoc """
  A step by step recreation of every step of a game.

  We only do 2 rounds for brevity.
  """
  alias ViralSpiral.Room.StateTransformation
  alias ViralSpiral.Canon.Card.Sparse
  alias ViralSpiral.Canon.Encyclopedia
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

    current_card = StateTransformation.active_card(state, current_player.id, 0)

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

    current_card = StateTransformation.active_card(state, player_b, 0) |> IO.inspect()

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

  describe "check source power" do
    setup do
      state = %State{
        room: %Room{
          id: "room_abc",
          name: "crazy-house-3213",
          state: :running,
          unjoined_players: [],
          affinities: [:skub, :houseboat],
          communities: [:red, :yellow, :blue],
          chaos: 0,
          chaos_counter: 10,
          volatality: :medium
        },
        players: %{
          "player_abc" => %Player{
            id: "player_abc",
            name: "farah",
            biases: %{yellow: 0, blue: 0},
            affinities: %{skub: 0, houseboat: 0},
            clout: 0,
            identity: :red,
            hand: [],
            active_cards: []
          },
          "player_def" => %Player{
            id: "player_def",
            name: "aman",
            biases: %{red: 0, blue: 0},
            affinities: %{skub: 0, houseboat: 0},
            clout: 0,
            identity: :yellow,
            hand: [],
            active_cards: []
          },
          "player_ghi" => %Player{
            id: "player_ghi",
            name: "krys",
            biases: %{yellow: 0, blue: 0},
            affinities: %{skub: 0, houseboat: 0},
            clout: 0,
            identity: :red,
            hand: [],
            active_cards: []
          },
          "player_jkl" => %Player{
            id: "player_jkl",
            biases: %{yellow: 0, blue: 0},
            affinities: %{skub: 0, houseboat: 0},
            clout: 0,
            name: "adhiraj",
            identity: :red,
            hand: [],
            active_cards: []
          }
        },
        round: %Round{
          order: ["player_jkl", "player_ghi", "player_def", "player_abc"],
          count: 4,
          current: 0,
          skip: nil
        },
        turn: %Turn{
          card: nil,
          current: "player_jkl",
          pass_to: ["player_abc", "player_def", "player_ghi"]
        }
      }

      state = %{state | deck: Factory.new_deck(state.room)}

      %{state: state}
    end

    test "view/hide source for true affinity card", %{state: state} do
      state = state |> Factory.draw_card(type: :affinity, target: :skub, veracity: true)
      current_player = State.current_turn_player(state)
      active_card = current_player.active_cards |> hd
      card = Sparse.new(active_card)

      state = state |> Factory.view_source(current_player.id, card.id, card.veracity)
      key = "#{current_player.id}_#{card.id}_#{card.veracity}"
      assert state.power_check_source.map[key] != nil

      state = state |> Factory.close_source(current_player.id, card.id, card.veracity)
      assert state.power_check_source.map[key] == nil
    end

    test "view/hide source for false affinity card", %{state: state} do
      state = state |> Factory.draw_card(type: :affinity, target: :houseboat, veracity: false)
      current_player = State.current_turn_player(state)
      active_card = current_player.active_cards |> hd
      card = Sparse.new(active_card)

      state = state |> Factory.view_source(current_player.id, card.id, card.veracity)
      key = "#{current_player.id}_#{card.id}_#{card.veracity}"
      assert state.power_check_source.map[key] != nil

      state = state |> Factory.close_source(current_player.id, card.id, card.veracity)
      assert state.power_check_source.map[key] == nil
    end
  end
end
