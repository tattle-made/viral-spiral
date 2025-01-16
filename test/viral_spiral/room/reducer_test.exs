defmodule ViralSpiral.Room.ReducerTest do
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
end
