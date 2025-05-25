defmodule ViralSpiral.Room.ReducerTest do
  require IEx
  alias ViralSpiral.Canon.Deck.CardSet
  alias ViralSpiral.Room.Actions.Player.PassCard
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
      current_player = State.current_round_player(state)
      # assert Deck.size(new_state.deck.available_cards, draw_type) == 59
      assert length(current_player.active_cards) == 1
    end
  end

  describe "pass card" do
    setup do
      :rand.seed(:exsss, {123, 135, 254})
      {state, players} = StateFixtures.new_game_with_four_players()
      %{state: state, players: players}
    end

    test "pass affinity card", %{state: state, players: players} do
      %{adhiraj: adhiraj, aman: aman, farah: farah, krys: krys} = players

      state =
        state
        |> StateFixtures.update_round(%{order: [adhiraj, aman, krys, farah]})
        |> StateFixtures.update_turn(%{current: adhiraj, pass_to: [aman, krys, farah]})

      card_sets = state.deck.available_cards
      set_key = CardSet.key(:affinity, true, :houseboat)
      cardset_member = Deck.draw_card(card_sets, set_key, 4)
      sparse_card = Sparse.new(cardset_member.id, true)

      state = state |> StateFixtures.update_player(adhiraj, %{active_cards: [sparse_card]})

      pass_card_attrs = %{
        from_id: adhiraj,
        to_id: aman,
        card: %{
          id: cardset_member.id,
          veracity: true
        }
      }

      state = Reducer.reduce(state, Actions.pass_card(pass_card_attrs))

      assert state.players[adhiraj].clout == 1
      assert state.players[adhiraj].affinities.houseboat == -1
      assert state.players[aman].active_cards |> length() == 1
    end

    test "pass bias card", %{state: state, players: players} do
      %{adhiraj: adhiraj, aman: aman, farah: farah, krys: krys} = players

      state =
        state
        |> StateFixtures.update_round(%{order: [adhiraj, aman, krys, farah]})
        |> StateFixtures.update_turn(%{current: adhiraj, pass_to: [aman, krys, farah]})

      card_sets = state.deck.available_cards
      set_key = CardSet.key(:bias, true, :red)
      cardset_member = Deck.draw_card(card_sets, set_key, 4)
      sparse_card = Sparse.new(cardset_member.id, true)

      state = state |> StateFixtures.update_player(adhiraj, %{active_cards: [sparse_card]})

      pass_card_attrs = %{
        from_id: adhiraj,
        to_id: aman,
        card: %{
          id: cardset_member.id,
          veracity: true
        }
      }

      state = Reducer.reduce(state, Actions.pass_card(pass_card_attrs))

      assert state.players[adhiraj].clout == 1
      assert state.players[adhiraj].biases.red == 1
      assert state.players[aman].active_cards |> length() == 1
    end

    test "pass topical card", %{state: state, players: players} do
      %{adhiraj: adhiraj, aman: aman, farah: farah, krys: krys} = players

      state =
        state
        |> StateFixtures.update_round(%{order: [adhiraj, aman, krys, farah]})
        |> StateFixtures.update_turn(%{current: adhiraj, pass_to: [aman, krys, farah]})

      card_sets = state.deck.available_cards
      set_key = CardSet.key(:topical, true, nil)
      cardset_member = Deck.draw_card(card_sets, set_key, 4)
      sparse_card = Sparse.new(cardset_member.id, true)

      state = state |> StateFixtures.update_player(adhiraj, %{active_cards: [sparse_card]})

      pass_card_attrs = %{
        from_id: adhiraj,
        to_id: aman,
        card: %{
          id: cardset_member.id,
          veracity: true
        }
      }

      state = Reducer.reduce(state, Actions.pass_card(pass_card_attrs))

      assert state.players[adhiraj].clout == 1
      assert state.players[aman].active_cards |> length() == 1
    end
  end

  describe "check source" do
    setup do
      :rand.seed(:exsss, {123, 135, 254})
      {state, players} = StateFixtures.new_game_with_four_players()
      %{state: state, players: players}
    end

    test "view and hide source", %{state: state, players: players} do
      %{adhiraj: adhiraj} = players

      card_sets = state.deck.available_cards
      set_key = CardSet.key(:bias, true, :red)
      cardset_member = Deck.draw_card(card_sets, set_key, 4)

      attrs = %{
        from_id: adhiraj,
        card: %{
          id: cardset_member.id,
          veracity: true
        }
      }

      state = Reducer.reduce(state, Actions.view_source(attrs))
      sparse_card = Sparse.new(cardset_member.id, true)
      assert state.players[adhiraj].open_articles[sparse_card] != nil
      player_article = state.players[adhiraj].open_articles[sparse_card]
      assert player_article.card_id == sparse_card.id
      assert player_article.veracity == true

      state = Reducer.reduce(state, Actions.hide_source(attrs))
      assert state.players[adhiraj].open_articles[sparse_card] == nil
    end
  end

  describe "mark as fake" do
    setup do
      :rand.seed(:exsss, {123, 135, 254})
      {state, players} = StateFixtures.new_game_with_four_players()
      %{adhiraj: adhiraj, aman: aman, farah: farah, krys: krys} = players

      state =
        state
        |> StateFixtures.update_round(%{order: [adhiraj, aman, farah, krys]})
        |> StateFixtures.update_turn(%{
          current: farah,
          pass_to: [krys],
          path: [adhiraj, aman]
        })

      %{state: state, players: players}
    end

    # farah has received a true card from aman
    # We will force draw a true card and then have farah mark it as fake
    test "mark true card as fake", %{state: state, players: players} do
      %{farah: farah, aman: aman} = players
      card_sets = state.deck.available_cards
      set_key = CardSet.key(:bias, true, :red)
      cardset_member = Deck.draw_card(card_sets, set_key, 4)
      sparse_card = Sparse.new(cardset_member.id, true)

      state =
        state
        |> StateFixtures.update_player(farah, %{active_cards: [sparse_card]})

      mark_as_fake_attrs = %{
        from_id: farah,
        card: %{
          id: cardset_member.id,
          veracity: true
        }
      }

      state = Reducer.reduce(state, Actions.mark_card_as_fake(mark_as_fake_attrs))
      assert state.players[farah].clout == -1
      assert state.players[aman].clout == 0
    end

    # farah has received a fake card from aman
    # We will force draw a fake card and then have farah mark it as fake
    test "mark false card as fake", %{state: state, players: players} do
      %{farah: farah, aman: aman} = players
      card_sets = state.deck.available_cards
      set_key = CardSet.key(:bias, false, :red)
      cardset_member = Deck.draw_card(card_sets, set_key, 4)
      sparse_card = Sparse.new(cardset_member.id, false)

      state =
        state
        |> StateFixtures.update_player(farah, %{active_cards: [sparse_card]})

      mark_as_fake_attrs = %{
        from_id: farah,
        card: %{
          id: cardset_member.id,
          veracity: false
        }
      }

      state = Reducer.reduce(state, Actions.mark_card_as_fake(mark_as_fake_attrs))
      assert state.players[farah].clout == 0
      assert state.players[aman].clout == -1
    end
  end

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
