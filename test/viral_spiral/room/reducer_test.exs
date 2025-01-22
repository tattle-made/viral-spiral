defmodule ViralSpiral.Room.ReducerTest do
  require IEx
  alias ViralSpiral.Room.Card.Player, as: CardPlayer
  alias ViralSpiral.Entity.Turn
  alias ViralSpiral.Entity.Round
  alias ViralSpiral.Entity.Player
  alias ViralSpiral.Canon.Card.Sparse
  alias ViralSpiral.Canon.Article
  alias ViralSpiral.Entity.PlayerMap
  alias ViralSpiral.Room.Factory
  alias ViralSpiral.Room.Actions
  alias ViralSpiral.Room.ChangeDescriptions
  alias ViralSpiral.Entity.Change
  alias ViralSpiral.Canon.Deck
  alias ViralSpiral.Room.Reducer
  alias ViralSpiral.Room.State
  alias ViralSpiral.Entity.Room
  use ExUnit.Case

  describe "" do
    setup do
      :rand.seed(:exsss, {123, 135, 254})

      room = Room.reserve("test-room") |> Room.start(4)
      state = State.new(room, ["adhiraj", "krys", "aman", "farah"])

      %{state: state}
    end

    @tag timeout: :infinity
    test "draw_card", %{state: state} do
      requirements = Factory.draw_type(state)
      draw_type = Deck.draw_type(requirements)
      assert Deck.size(state.deck.available_cards, draw_type) == 60

      new_state = Reducer.reduce(state, Actions.draw_card(draw_type))

      assert Deck.size(new_state.deck.available_cards, draw_type) == 59

      current_player = State.current_round_player(new_state)
      assert length(current_player.active_cards) == 1
    end

    test "keep_card" do
    end

    test "discard_card" do
    end

    test "check_source" do
    end

    test "turn_to_fake" do
    end

    test "cancel_player" do
    end
  end

  describe "viral spiral" do
    setup do
      :rand.seed(:exsss, {123, 135, 254})

      state = StateFixtures.new_state()
      players = StateFixtures.player_by_names(state)

      %{state: state, players: players}
    end

    test "pass to two players", %{state: state, players: players} do
      %{adhiraj: adhiraj, krys: krys} = players

      IO.inspect(adhiraj.identity)
      IO.inspect(adhiraj.affinities)
      IO.inspect(adhiraj.biases)
      IO.inspect(adhiraj.active_cards)
      # IO.inspect(state)
      current_player = State.current_turn_player(state)

      IO.inspect(current_player)

      others = PlayerMap.others(state.players, current_player.id)

      requirements = Factory.draw_type(state)
      draw_type = Deck.draw_type(requirements)
      new_state = Reducer.reduce(state, Actions.draw_card(draw_type))

      # IO.inspect(new_state.players[current_player.id])

      # test if the action creates power_viral_spiral struct
      # test if further passes modify the power_viral_spiral struct
      # test score(?)

      # IO.inspect(new_state.round)
      # IO.inspect(new_state.turn)
      # IO.inspect(new_state.players)

      # IO.inspect(state.players[krys.id], label: "before")

      # krys = %{state.players[krys.id] | clout: 4, affinities: %{sock: 2, houseboat: 5}}
      # new_state = %{state | players: %{state.players | krys.id => krys}}
      # IO.inspect(new_state.players, label: "new state")

      # IO.inspect(krys, label: "after")
    end
  end

  describe "pass card" do
    setup do
      :rand.seed(:exsss, {12356, 123_534, 345_345})

      room = Room.reserve("test-room") |> Room.start(4)
      state = State.new(room, ["adhiraj", "krys", "aman", "farah"])

      players = StateFixtures.player_by_names(state)

      %{state: state, players: players}
    end

    test "passing affinity card", %{state: state, players: players} do
      sets = state.deck.available_cards
      store = state.deck.store
      %{aman: aman, adhiraj: adhiraj} = players

      draw_type = [type: :affinity, veracity: true, tgb: 2, target: :skub]
      draw_result = Deck.draw_card(sets, draw_type)
      card = store[{draw_result.id, true}]

      new_state =
        Reducer.reduce(state, Actions.pass_card(card.id, card.veracity, aman.id, adhiraj.id))

      assert new_state.players[aman.id].affinities[:skub] == 1
      assert new_state.players[aman.id].clout == 1
      assert new_state.players[adhiraj.id].active_cards |> length == 1
      assert new_state.turn.current == adhiraj.id
      assert new_state.turn.pass_to |> length() == 2
    end
  end

  @tag timeout: :infinity
  describe "view source" do
    setup do
      :rand.seed(:exsss, {12356, 123_534, 345_345})
      state = Fixtures.new_game()
      players = Fixtures.player_by_names(state)

      %{state: state, players: players}
    end

    test "true card", %{state: state, players: players} do
      %{aman: aman, farah: farah} = players
      sets = state.deck.available_cards
      store = state.deck.store

      draw_type = [type: :affinity, veracity: true, tgb: 2, target: :skub]
      draw_result = Deck.draw_card(sets, draw_type)
      card = store[{draw_result.id, true}] |> IO.inspect()

      article = state.deck.article_store[{card.id, card.veracity}]
      IO.inspect(state.deck.article_store[{card.id, card.veracity}])
      assert article.veracity == true
      assert article.card_id == "card_131675249"
      assert article.type == "News"

      # IO.inspect(draw_result)
      # IO.inspect(card)

      # state = Reducer.reduce(state, Actions.view_source())
      # IO.inspect(state.players[aman.id])
    end
  end

  # @tag timeout: :infinity
  # test "temp" do
  #   :rand.seed(:exsss, {12356, 123_534, 345_345})
  #   store = StateFixtures.new_state()
  #   store = StateFixtures.set_chaos(store, 4)

  #   %{adhiraj: adhiraj, aman: aman, farah: farah, krys: krys} =
  #     StateFixtures.player_by_names(store)

  #   # draw card of a certain type(?)

  #   Change.apply_change(store.players[aman.id], Options.change_clout(2))

  #   # IO.inspect(store.round)
  #   # IO.inspect(store.turn)
  #   # IO.inspect(store.players)
  #   # IO.inspect(store.room)
  # end

  describe "mark as fake" do
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
          current: 1,
          skip: nil
        },
        turn: %Turn{
          current: "player_ghi",
          pass_to: ["player_def"],
          path: ["player_abc", "player_jkl"]
        }
      }

      state = %{state | deck: Factory.new_deck(state.room)}

      %{state: state}
    end

    # player_ghi has received a card from player_jkl
    # We will force this card to be a true card and then have player_ghi mark it as fake
    @tag timeout: :infinity
    test "mark true card as fake", %{state: state} do
      from = State.current_turn_player(state)
      card = %Sparse{id: "card_121565043", veracity: true}
      turn = state.turn

      state = Reducer.reduce(state, Actions.mark_card_as_fake(from, card, turn))
      assert state.players["player_ghi"].clout == -1
      assert state.players["player_jkl"].clout == 0
    end

    test "mark false card as fake", %{state: state} do
      from = State.current_turn_player(state)
      card = %Sparse{id: "card_121565043", veracity: false}
      turn = state.turn

      state = Reducer.reduce(state, Actions.mark_card_as_fake(from, card, turn))
      assert state.players["player_ghi"].clout == 0
      assert state.players["player_jkl"].clout == -1
    end
  end

  describe "turn card to fake" do
    setup do
      state = StateFixtures.new_game()
      state = %{state | deck: Factory.new_deck(state.room)}
      active_cards = [{"card_94393892", true, "true headline"}]
      state = put_in(state.players["player_abc"].active_cards, active_cards)

      %{state: state}
    end

    test "turn card to fake", %{state: state} do
      action_attr = %{
        "player_id" => "player_abc",
        "card" => %{
          "id" => "card_94393892",
          "type" => :affinity,
          "veracity" => true,
          "target" => :skub
        }
      }

      player = State.current_turn_player(state)
      active_card = State.active_card(state, player.id, 0)
      assert active_card.id == "card_94393892"
      assert active_card.veracity == true

      action = Actions.turn_to_fake(action_attr)
      state = Reducer.reduce(state, action)
      active_card = State.active_card(state, player.id, 0)
      assert active_card.id == "card_94393892"
      assert active_card.veracity == false

      # todo assert headline too
    end
  end
end
