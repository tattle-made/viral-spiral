defmodule ViralSpiral.Room.ReducerTest do
  require IEx
  alias ViralSpiral.Entity.PowerCancelPlayer.Exceptions.VoteAlreadyRegistered
  alias ViralSpiral.Room.StateTransformation
  alias ViralSpiral.Canon.Deck.CardSet
  alias ViralSpiral.Canon.Card.Sparse
  alias ViralSpiral.Room.Actions
  alias ViralSpiral.Canon.Deck
  alias ViralSpiral.Room.Reducer
  alias ViralSpiral.Room.State
  alias ViralSpiral.Entity.Room
  use ExUnit.Case

  test "room setup" do
    :rand.seed(:exsss, {645, 135, 722})
    state = State.skeleton()

    reserve_room_attrs = %{player_name: "adhiraj"}
    state = Reducer.reduce(state, Actions.reserve_room(reserve_room_attrs))

    join_room_attrs_a = %{player_name: "aman"}
    state = Reducer.reduce(state, Actions.join_room(join_room_attrs_a))

    join_room_attrs_b = %{player_name: "farah"}
    state = Reducer.reduce(state, Actions.join_room(join_room_attrs_b))

    join_room_attrs_c = %{player_name: "krys"}
    state = Reducer.reduce(state, Actions.join_room(join_room_attrs_c))

    _state = Reducer.reduce(state, Actions.start_game())
    assert 1 == 1
  end

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

  describe "draw dynamic card" do
    setup do
      :rand.seed(:exsss, {74455, 8374, 7333})

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

    test "dynamic card", %{state: state} do
      state = state |> StateTransformation.update_room(%{chaos: 8})
      state = Reducer.reduce(state, Actions.draw_card())
      assert Map.keys(state.dynamic_card.identity_stats) |> length() == 1
    end
  end

  describe "pass card" do
    setup do
      :rand.seed(:exsss, {123, 135, 254})
      {state, players} = StateFixtures.new_game_with_four_players()
      %{state: state, players: players}
    end

    test "affinity card", %{state: state, players: players} do
      %{adhiraj: adhiraj, aman: aman, farah: farah, krys: krys} = players

      state =
        state
        |> StateTransformation.update_round(%{order: [adhiraj, aman, krys, farah]})
        |> StateTransformation.update_turn(%{current: adhiraj, pass_to: [aman, krys, farah]})

      card_sets = state.deck.available_cards
      set_key = CardSet.key(:affinity, true, :houseboat)
      cardset_member = Deck.draw_card(card_sets, set_key, 4)
      sparse_card = Sparse.new(cardset_member.id, true)

      state = state |> StateTransformation.update_player(adhiraj, %{active_cards: [sparse_card]})

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
      assert state.players[adhiraj].affinities.houseboat == 1
      assert state.players[aman].active_cards |> length() == 1
    end

    test "bias card", %{state: state, players: players} do
      %{adhiraj: adhiraj, aman: aman, farah: farah, krys: krys} = players

      state =
        state
        |> StateTransformation.update_player(adhiraj, %{
          identity: :yellow,
          biases: %{red: 0, blue: 0}
        })
        |> StateTransformation.update_player(aman, %{
          identity: :red,
          biases: %{yellow: 0, blue: 0}
        })
        |> StateTransformation.update_player(farah, %{
          identity: :blue,
          biases: %{red: 0, yellow: 0}
        })
        |> StateTransformation.update_player(krys, %{
          identity: :red,
          biases: %{blue: 0, yellow: 0}
        })
        |> StateTransformation.update_round(%{order: [adhiraj, aman, krys, farah]})
        |> StateTransformation.update_turn(%{current: adhiraj, pass_to: [aman, krys, farah]})

      card_sets = state.deck.available_cards
      set_key = CardSet.key(:bias, true, :red)
      cardset_member = Deck.draw_card(card_sets, set_key, 4)
      sparse_card = Sparse.new(cardset_member.id, true)

      state = state |> StateTransformation.update_player(adhiraj, %{active_cards: [sparse_card]})

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
      assert state.players[aman].clout == -1
      assert state.players[krys].clout == -1
    end

    test "topical card", %{state: state, players: players} do
      %{adhiraj: adhiraj, aman: aman, farah: farah, krys: krys} = players

      state =
        state
        |> StateTransformation.update_round(%{order: [adhiraj, aman, krys, farah]})
        |> StateTransformation.update_turn(%{current: adhiraj, pass_to: [aman, krys, farah]})

      card_sets = state.deck.available_cards
      set_key = CardSet.key(:topical, true, nil)
      cardset_member = Deck.draw_card(card_sets, set_key, 4)
      sparse_card = Sparse.new(cardset_member.id, true)

      state = state |> StateTransformation.update_player(adhiraj, %{active_cards: [sparse_card]})

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

  describe "pass dynamic card" do
    setup do
      :rand.seed(:exsss, {123, 849, 254})
      {state, players} = StateFixtures.new_game_with_four_players()
      %{adhiraj: adhiraj, aman: aman, farah: farah, krys: krys} = players

      state =
        state
        |> StateTransformation.update_player(adhiraj, %{
          identity: :yellow,
          clout: 5,
          biases: %{red: 2, blue: 5}
        })
        |> StateTransformation.update_player(aman, %{
          identity: :red,
          clout: 5,
          biases: %{yellow: 0, blue: 4}
        })
        |> StateTransformation.update_player(farah, %{
          identity: :blue,
          clout: 5,
          biases: %{red: 1, yellow: 5}
        })
        |> StateTransformation.update_player(krys, %{
          identity: :blue,
          clout: 5,
          biases: %{red: 3, yellow: 3}
        })
        |> StateTransformation.update_round(%{order: [adhiraj, aman, krys, farah]})
        |> StateTransformation.update_turn(%{current: adhiraj, pass_to: [aman, krys, farah]})

      %{state: state, players: players}
    end

    test "topical card", %{state: state, players: players} do
      %{adhiraj: adhiraj, aman: aman, farah: farah, krys: krys} = players

      # card id corresponds to a known topical card in deck
      # given the player biases, after dynamic patching, this card should have an anti red bias
      sparse_card = Sparse.new("card_80978491", false)

      state = state |> Reducer.reduce(Actions.draw_card(%{card: sparse_card}))

      pass_attrs = %{
        from_id: adhiraj,
        to_id: aman,
        card: %{
          id: "card_80978491",
          veracity: false
        }
      }

      state = state |> Reducer.reduce(Actions.pass_card(pass_attrs))
      new_adhiraj = state.players[adhiraj]
      new_aman = state.players[aman]
      new_krys = state.players[krys]
      new_farah = state.players[farah]
      assert new_adhiraj.clout == 6
      assert new_adhiraj.biases.red == 3
      assert new_aman.clout == 4
    end
  end

  describe "keep card" do
    setup do
      :rand.seed(:exsss, {123, 135, 254})
      {state, players} = StateFixtures.new_game_with_four_players()
      %{adhiraj: adhiraj, aman: aman, farah: farah, krys: krys} = players

      state =
        state
        |> StateTransformation.update_round(%{order: [adhiraj, aman, krys, farah]})
        |> StateTransformation.update_turn(%{current: adhiraj, pass_to: [aman, krys, farah]})

      %{state: state, players: players}
    end

    test "keep affinity card", %{state: state, players: players} do
      %{adhiraj: adhiraj, aman: _aman, farah: _farah, krys: _krys} = players
      sparse_card = StateTransformation.draw_card(state, {:affinity, true, :houseboat})

      state = StateTransformation.update_player(state, adhiraj, %{active_cards: [sparse_card]})

      keep_card_attrs = %{
        from_id: adhiraj,
        card: %{
          id: sparse_card.id,
          veracity: true
        }
      }

      state = Reducer.reduce(state, Actions.keep_card(keep_card_attrs))
      assert state.players[adhiraj].clout == 0
      assert state.players[adhiraj].hand |> length() == 1
      assert state.players[adhiraj].active_cards |> length() == 0
    end

    test "keep bias card", %{state: state, players: players} do
      %{adhiraj: adhiraj, aman: _aman, farah: _farah, krys: _krys} = players

      sparse_card = StateTransformation.draw_card(state, {:bias, true, :yellow})

      state =
        StateTransformation.update_player(state, adhiraj, %{active_cards: [sparse_card]})
        |> StateTransformation.update_player(adhiraj, %{
          identity: :red,
          biases: %{yellow: 3, blue: 0}
        })

      keep_card_attrs = %{
        from_id: adhiraj,
        card: %{
          id: sparse_card.id,
          veracity: true
        }
      }

      state = Reducer.reduce(state, Actions.keep_card(keep_card_attrs))
      assert state.players[adhiraj].hand |> length() == 1
      assert state.players[adhiraj].active_cards |> length() == 0
      assert state.players[adhiraj].clout == 0
    end

    test "keep same identity bias card as the player", %{state: state, players: players} do
      %{adhiraj: adhiraj, aman: _aman, farah: farah, krys: _krys} = players
      bias_card = StateTransformation.draw_card(state, {:bias, true, :red})

      state =
        StateTransformation.update_player(state, farah, %{clout: 4, active_cards: [bias_card]})

      IO.inspect(state.players[farah], label: "STATE")

      keep_card_attrs = %{
        from_id: farah,
        card: %{
          id: bias_card.id,
          veracity: true
        }
      }

      state = Reducer.reduce(state, Actions.keep_card(keep_card_attrs))
      assert state.players[farah].clout == 4
    end
  end

  describe "discard card" do
    setup do
      :rand.seed(:exsss, {123, 135, 254})
      {state, players} = StateFixtures.new_game_with_four_players()
      %{adhiraj: adhiraj, aman: aman, farah: farah, krys: krys} = players

      state =
        state
        |> StateTransformation.update_round(%{order: [adhiraj, aman, krys, farah]})
        |> StateTransformation.update_turn(%{current: adhiraj, pass_to: [aman, krys, farah]})

      %{state: state, players: players}
    end

    test "discard bias card", %{state: state, players: players} do
      %{adhiraj: adhiraj, aman: _aman, farah: _farah, krys: _krys} = players

      sparse_card = StateTransformation.draw_card(state, {:bias, true, :yellow})

      state =
        StateTransformation.update_player(state, adhiraj, %{active_cards: [sparse_card]})
        |> StateTransformation.update_player(adhiraj, %{
          identity: :red,
          biases: %{yellow: 3, blue: 0}
        })

      discard_card_attrs = %{
        from_id: adhiraj,
        card: %{
          id: sparse_card.id,
          veracity: true
        }
      }

      state = Reducer.reduce(state, Actions.discard_card(discard_card_attrs))
      assert state.players[adhiraj].hand |> length() == 0
      assert state.players[adhiraj].active_cards |> length() == 0
      assert state.players[adhiraj].clout == 0
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
        |> StateTransformation.update_round(%{order: [adhiraj, aman, farah, krys]})
        |> StateTransformation.update_turn(%{
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
        |> StateTransformation.update_player(farah, %{active_cards: [sparse_card]})

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
        |> StateTransformation.update_player(farah, %{active_cards: [sparse_card]})

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

  describe "turn to fake" do
    setup do
      :rand.seed(:exsss, {123, 135, 254})
      {state, players} = StateFixtures.new_game_with_four_players()
      %{adhiraj: adhiraj, aman: aman, farah: farah, krys: krys} = players

      state =
        state
        |> StateTransformation.update_round(%{order: [adhiraj, aman, farah, krys]})
        |> StateTransformation.update_turn(%{
          current: adhiraj,
          pass_to: [aman, farah, krys],
          path: []
        })

      %{state: state, players: players}
    end

    test "true card", %{state: state, players: players} do
      %{farah: farah} = players
      card_sets = state.deck.available_cards
      set_key = CardSet.key(:affinity, true, :houseboat)
      cardset_member = Deck.draw_card(card_sets, set_key, 4)
      sparse_card = Sparse.new(cardset_member.id, true)

      state =
        state
        |> StateTransformation.update_player(farah, %{active_cards: [sparse_card]})

      attrs = %{
        from_id: farah,
        card: %{
          id: cardset_member.id,
          veracity: true
        }
      }

      active_card = StateTransformation.active_card(state, farah, 0)
      assert active_card.veracity == true
      state = Reducer.reduce(state, Actions.turn_to_fake(attrs))
      active_card = StateTransformation.active_card(state, farah, 0)
      assert active_card.veracity == false
    end

    test "false card", %{state: state, players: players} do
      %{farah: farah} = players
      card_sets = state.deck.available_cards
      set_key = CardSet.key(:affinity, false, :houseboat)
      cardset_member = Deck.draw_card(card_sets, set_key, 4)
      sparse_card = Sparse.new(cardset_member.id, false)

      state =
        state
        |> StateTransformation.update_player(farah, %{active_cards: [sparse_card]})

      attrs = %{
        from_id: farah,
        card: %{
          id: cardset_member.id,
          veracity: false
        }
      }

      active_card = StateTransformation.active_card(state, farah, 0)
      assert active_card.veracity == false

      assert_raise RuntimeError, "This card is already false", fn ->
        Reducer.reduce(state, Actions.turn_to_fake(attrs))
      end
    end
  end

  describe "cancel player" do
    setup do
      :rand.seed(:exsss, {123, 899, 254})
      {state, players} = StateFixtures.new_game_with_four_players()
      %{adhiraj: adhiraj, aman: aman, farah: farah, krys: krys} = players

      state =
        state
        |> StateTransformation.update_player(adhiraj, %{affinities: %{sock: 5, skub: 0}})
        |> StateTransformation.update_player(adhiraj, %{
          active_cards: [Sparse.new("card_30181728", true)]
        })
        |> StateTransformation.update_player(aman, %{affinities: %{sock: 2, skub: 0}})
        |> StateTransformation.update_player(farah, %{affinities: %{sock: 2, skub: 0}})
        |> StateTransformation.update_player(krys, %{affinities: %{sock: -1, skub: 4}})
        |> StateTransformation.update_round(%{order: [adhiraj, aman, krys, farah]})
        |> StateTransformation.update_turn(%{current: adhiraj, pass_to: [aman, krys, farah]})

      %{state: state, players: players}
    end

    test "successful cancellation flow", %{state: state, players: players} do
      %{adhiraj: adhiraj, aman: aman, farah: farah, krys: krys} = players

      initiate_cancel_attrs = %{
        from_id: adhiraj,
        target_id: krys,
        affinity: :sock
      }

      state = Reducer.reduce(state, Actions.initiate_cancel(initiate_cancel_attrs))
      assert state.power_cancel_player.state == :waiting
      assert state.power_cancel_player.from == adhiraj
      assert state.power_cancel_player.target == krys
      assert state.power_cancel_player.affinity == :sock
      assert state.power_cancel_player.allowed_voters |> length() == 3
      assert state.players[adhiraj].affinities.sock == 4

      illegal_vote_cancel_attrs = %{from_id: adhiraj, vote: true}

      assert_raise VoteAlreadyRegistered, fn ->
        Reducer.reduce(state, Actions.vote_to_cancel(illegal_vote_cancel_attrs))
      end

      vote_cancel_attrs_a = %{from_id: aman, vote: true}
      state = Reducer.reduce(state, Actions.vote_to_cancel(vote_cancel_attrs_a))

      vote_cancel_attrs_b = %{from_id: farah, vote: true}
      state = Reducer.reduce(state, Actions.vote_to_cancel(vote_cancel_attrs_b))

      assert state.round.skip != nil
      assert state.round.skip.round == :current
      assert state.round.skip.player == krys
      assert state.power_cancel_player.state == :idle
    end
  end

  # we noticed 2 times consequetively that after a cancellation round
  # keep and discard were not behaving correctly.
  test "card action after cancellation" do
    :rand.seed(:exsss, {123, 899, 254})
    {state, players} = StateFixtures.new_game_with_four_players()
    %{adhiraj: adhiraj, aman: aman, farah: farah, krys: krys} = players

    %{state: state, players: players}
  end

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
end
