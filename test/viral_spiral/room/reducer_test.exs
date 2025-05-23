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

  describe "draw card" do
    setup do
      :rand.seed(:exsss, {123, 135, 254})

      room =
        Room.skeleton()
        |> Room.join("adhiraj")
        |> Room.set_state(:reserved)
        |> Room.join("aman")
        |> Room.join("farah")
        |> Room.join("krys")
        |> Room.start()

      state = %State{room: room}
      state = State.setup(state)

      %{state: state}
    end

    test "draw_card", %{state: state} do
      state = Reducer.reduce(state, Actions.draw_card())
      # assert Deck.size(new_state.deck.available_cards, draw_type) == 59
      assert length(current_player.active_cards) == 1
    end
  end

  # describe "pass card" do
  #   setup do
  #     # Setup a room with affinities :sock and :skub
  #     # and communities :red, :yellow and :blue
  #     # current player is named farah
  #     :rand.seed(:exsss, {12356, 123_534, 345_345})
  #     room = Room.reserve("test-room") |> Room.start(4)
  #     state = State.new(room, ["adhiraj", "krys", "aman", "farah"])

  #     %{state: state}
  #   end

  #   test "pass affinity card", %{state: state} do
  #     draw_type = [type: :affinity, target: :sock, veracity: true, tgb: 2]
  #     draw_card_action = Actions.draw_card(draw_type)
  #     state = Reducer.reduce(state, draw_card_action)

  #     %{farah: farah, adhiraj: adhiraj} = StateFixtures.player_by_names(state)
  #     card = StateFixtures.active_card(state, farah.id, 0)

  #     action =
  #       Actions.pass_card(%{
  #         "from_id" => farah.id,
  #         "to_id" => adhiraj.id,
  #         "card" => %{"id" => card.id, "veracity" => card.veracity}
  #       })

  #     state = Reducer.reduce(state, action)

  #     %{farah: farah, adhiraj: adhiraj} = StateFixtures.player_by_names(state)

  #     assert farah.affinities.sock == 1
  #     assert farah.clout == 1
  #     assert adhiraj.active_cards == [{"card_82969419", true}]
  #   end

  #   test "pass bias card", %{state: state} do
  #     draw_type = [type: :bias, target: :red, veracity: true, tgb: 2]
  #     draw_card_action = Actions.draw_card(draw_type)
  #     state = Reducer.reduce(state, draw_card_action)

  #     %{farah: farah, adhiraj: adhiraj} = StateFixtures.player_by_names(state)
  #     card = StateFixtures.active_card(state, farah.id, 0)

  #     action =
  #       Actions.pass_card(%{
  #         "from_id" => farah.id,
  #         "to_id" => adhiraj.id,
  #         "card" => %{"id" => card.id, "veracity" => card.veracity}
  #       })

  #     state = Reducer.reduce(state, action)

  #     %{farah: farah, adhiraj: adhiraj, aman: aman, krys: krys} =
  #       StateFixtures.player_by_names(state)

  #     assert farah.biases.red == 1
  #     assert farah.clout == 1
  #     assert adhiraj.active_cards == [{"card_4168848", true}]
  #     assert aman.clout == -1
  #     assert krys.clout == -1
  #   end

  #   test "pass topical card", %{state: state} do
  #     draw_type = [type: :topical, veracity: true, tgb: 2]
  #     draw_card_action = Actions.draw_card(draw_type)
  #     state = Reducer.reduce(state, draw_card_action)

  #     %{farah: farah, adhiraj: adhiraj} = StateFixtures.player_by_names(state)
  #     card = StateFixtures.active_card(state, farah.id, 0)

  #     action =
  #       Actions.pass_card(%{
  #         "from_id" => farah.id,
  #         "to_id" => adhiraj.id,
  #         "card" => %{"id" => card.id, "veracity" => card.veracity}
  #       })

  #     state = Reducer.reduce(state, action)

  #     %{farah: farah, adhiraj: adhiraj, aman: aman, krys: krys} =
  #       StateFixtures.player_by_names(state)

  #     assert farah.clout == 1
  #     assert adhiraj.active_cards == [{"card_63010791", true}]
  #   end
  # end

  # describe "check source" do
  #   import Fixtures

  #   setup do
  #     :rand.seed(:exsss, {12356, 123_534, 345_345})

  #     state = new_game()
  #     players = player_by_names(state)
  #     %{farah: farah} = players
  #     state = state |> add_active_card(farah.id, %{id: "card_88743234", veracity: true})

  #     %{state: state, players: players}
  #   end

  #   test "true card", %{state: state, players: players} do
  #     %{aman: aman, farah: farah} = players
  #     card = StateFixtures.active_card(state, farah.id, 0)

  #     action_attr = %{
  #       "from_id" => farah.id,
  #       "card" => %{
  #         "id" => card.id,
  #         "veracity" => card.veracity
  #       }
  #     }

  #     view_source_action = Actions.view_source(action_attr)
  #     state = Reducer.reduce(state, view_source_action)
  #     source = state.power_check_source.map[{farah.id, card.id, card.veracity}]

  #     assert source.owner == farah.id
  #     assert source.headline == "A skub a day keeps the blues away!"
  #     assert source.author == "City Desk"
  #   end
  # end

  # describe "mark as fake" do
  #   setup do
  #     state = %State{
  #       room: %Room{
  #         id: "room_abc",
  #         name: "crazy-house-3213",
  #         state: :running,
  #         unjoined_players: [],
  #         affinities: [:skub, :houseboat],
  #         communities: [:red, :yellow, :blue],
  #         chaos: 0,
  #         chaos_counter: 10,
  #         volatality: :medium
  #       },
  #       players: %{
  #         "player_abc" => %Player{
  #           id: "player_abc",
  #           name: "farah",
  #           biases: %{yellow: 0, blue: 0},
  #           affinities: %{skub: 0, houseboat: 0},
  #           clout: 0,
  #           identity: :red,
  #           hand: [],
  #           active_cards: []
  #         },
  #         "player_def" => %Player{
  #           id: "player_def",
  #           name: "aman",
  #           biases: %{red: 0, blue: 0},
  #           affinities: %{skub: 0, houseboat: 0},
  #           clout: 0,
  #           identity: :yellow,
  #           hand: [],
  #           active_cards: []
  #         },
  #         "player_ghi" => %Player{
  #           id: "player_ghi",
  #           name: "krys",
  #           biases: %{yellow: 0, blue: 0},
  #           affinities: %{skub: 0, houseboat: 0},
  #           clout: 0,
  #           identity: :red,
  #           hand: [],
  #           active_cards: []
  #         },
  #         "player_jkl" => %Player{
  #           id: "player_jkl",
  #           biases: %{yellow: 0, blue: 0},
  #           affinities: %{skub: 0, houseboat: 0},
  #           clout: 0,
  #           name: "adhiraj",
  #           identity: :red,
  #           hand: [],
  #           active_cards: []
  #         }
  #       },
  #       round: %Round{
  #         order: ["player_jkl", "player_ghi", "player_def", "player_abc"],
  #         count: 4,
  #         current: 1,
  #         skip: nil
  #       },
  #       turn: %Turn{
  #         current: "player_ghi",
  #         pass_to: ["player_def"],
  #         path: ["player_abc", "player_jkl"]
  #       }
  #     }

  #     state = %{state | deck: Factory.new_deck(state.room)}

  #     %{state: state}
  #   end

  #   # player_ghi has received a card from player_jkl
  #   # We will force this card to be a true card and then have player_ghi mark it as fake
  #   test "mark true card as fake", %{state: state} do
  #     from = State.current_turn_player(state)
  #     card = %Sparse{id: "card_121565043", veracity: true}
  #     turn = state.turn

  #     state = Reducer.reduce(state, Actions.mark_card_as_fake(from, card, turn))
  #     assert state.players["player_ghi"].clout == -1
  #     assert state.players["player_jkl"].clout == 0
  #   end

  #   test "mark false card as fake", %{state: state} do
  #     from = State.current_turn_player(state)
  #     card = %Sparse{id: "card_121565043", veracity: false}
  #     turn = state.turn

  #     state = Reducer.reduce(state, Actions.mark_card_as_fake(from, card, turn))
  #     assert state.players["player_ghi"].clout == 0
  #     assert state.players["player_jkl"].clout == -1
  #   end
  # end

  # describe "turn card to fake" do
  #   setup do
  #     state = StateFixtures.new_game()
  #     state = %{state | deck: Factory.new_deck(state.room)}
  #     active_cards = [{"card_94393892", true, "true headline"}]
  #     state = put_in(state.players["player_abc"].active_cards, active_cards)

  #     %{state: state}
  #   end

  #   test "turn card to fake", %{state: state} do
  #     action_attr = %{
  #       "player_id" => "player_abc",
  #       "card" => %{
  #         "id" => "card_94393892",
  #         "type" => :affinity,
  #         "veracity" => true,
  #         "target" => :skub
  #       }
  #     }

  #     player = State.current_turn_player(state)
  #     active_card = State.active_card(state, player.id, 0)
  #     assert active_card.id == "card_94393892"
  #     assert active_card.veracity == true

  #     action = Actions.turn_to_fake(action_attr)
  #     state = Reducer.reduce(state, action)
  #     active_card = State.active_card(state, player.id, 0)
  #     assert active_card.id == "card_94393892"
  #     assert active_card.veracity == false
  #   end
  # end

  # @tag timeout: :infinity
  # describe "viral spiral" do
  #   import Fixtures

  #   setup do
  #     # Setup a room with affinities :sock and :skub
  #     # and communities :red, :yellow and :blue
  #     # current player is named farah
  #     :rand.seed(:exsss, {12356, 123_534, 345_345})

  #     state = StateFixtures.new_state()
  #     players = StateFixtures.player_by_names(state)
  #     %{adhiraj: adhiraj} = players

  #     state =
  #       state
  #       |> add_active_card(adhiraj.id, %{id: "card_129231083", veracity: true, tgb: 2})

  #     %{state: state}
  #   end

  #   test "pass to two players", %{state: state} do
  #     # %{adhiraj: adhiraj, krys: krys} = players

  #     # IO.inspect(adhiraj.identity)
  #     # IO.inspect(adhiraj.affinities)
  #     # IO.inspect(adhiraj.biases)
  #     # IO.inspect(adhiraj.active_cards)
  #     # # IO.inspect(state)
  #     # current_player = State.current_turn_player(state)

  #     # IO.inspect(current_player)

  #     # others = PlayerMap.others(state.players, current_player.id)

  #     # requirements = Factory.draw_type(state)
  #     # draw_type = Deck.draw_type(requirements)
  #     # new_state = Reducer.reduce(state, Actions.draw_card(draw_type))

  #     # IO.inspect(new_state.players[current_player.id])

  #     # test if the action creates power_viral_spiral struct
  #     # test if further passes modify the power_viral_spiral struct
  #     # test score(?)

  #     # IO.inspect(new_state.round)
  #     # IO.inspect(new_state.turn)
  #     # IO.inspect(new_state.players)

  #     # IO.inspect(state.players[krys.id], label: "before")

  #     # krys = %{state.players[krys.id] | clout: 4, affinities: %{sock: 2, houseboat: 5}}
  #     # new_state = %{state | players: %{state.players | krys.id => krys}}
  #     # IO.inspect(new_state.players, label: "new state")

  #     # IO.inspect(krys, label: "after")
  #   end
  # end

  # describe "cancel someone" do
  #   setup do
  #     state = StateFixtures.new_game()
  #     state = %{state | deck: Factory.new_deck(state.room)}

  #     %{state: state}
  #   end

  #   @tag timeout: :infinity
  #   test "get one player to vote", %{state: state} do
  #     IO.inspect(state)
  #     require IEx
  #     # IEx.pry()
  #     # apply initiate_cancel action to state
  #     # apply cancel_vote action to state
  #     # compare final state
  #   end

  #   test "get more than one player to vote" do
  #   end
  # end
end
