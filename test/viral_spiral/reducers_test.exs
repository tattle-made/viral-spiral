defmodule ViralSpiral.ReducersTest do
  alias ViralSpiral.Gameplay.Factory
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

      current_player = State.current_round_player(state)
      assert length(current_player.active_cards) == 1
      IO.inspect(current_player)
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

    test "viral_spiral" do
    end
  end

  describe "pass card" do
    setup do
      :rand.seed(:exsss, {12356, 123_534, 345_345})

      room = Room.reserve("test-room") |> Room.start(4)
      state = State.new(room, ["adhiraj", "krys", "aman", "farah"])

      players = StoreFixtures.player_by_names(state)

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

  # @tag timeout: :infinity
  # test "temp" do
  #   :rand.seed(:exsss, {12356, 123_534, 345_345})
  #   store = StoreFixtures.new_store()
  #   store = StoreFixtures.set_chaos(store, 4)

  #   %{adhiraj: adhiraj, aman: aman, farah: farah, krys: krys} =
  #     StoreFixtures.player_by_names(store)

  #   # draw card of a certain type(?)

  #   Change.apply_change(store.players[aman.id], Options.change_clout(2))

  #   # IO.inspect(store.round)
  #   # IO.inspect(store.turn)
  #   # IO.inspect(store.players)
  #   # IO.inspect(store.room)
  # end
end
