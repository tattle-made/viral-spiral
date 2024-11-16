defmodule ViralSpiral.ReducersTest do
  alias ViralSpiral.GamePlay.Change.Options
  alias ViralSpiral.Room.State.Change
  alias ViralSpiral.Canon.Deck
  alias ViralSpiral.Reducers
  alias ViralSpiral.Room.State.Root
  alias ViralSpiral.Room.State.Room
  use ExUnit.Case

  describe "" do
    setup do
      :rand.seed(:exsss, {12356, 123_534, 345_345})

      room = Room.reserve("test-room") |> Room.start(4)
      state = Root.new(room, ["adhiraj", "krys", "aman", "farah"])

      %{state: state}
    end

    test "draw_card", %{state: state} do
      draw_type = [target: :yellow, type: :bias, veracity: false]
      assert Deck.size(state.deck.available_cards, draw_type) == 30

      new_state = Reducers.draw_card(state)

      assert Deck.size(new_state.deck.available_cards, draw_type) == 29

      current_player = new_state.players[new_state.turn.current]
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

    test "viral_spiral" do
    end
  end

  describe "pass card" do
    setup do
      :rand.seed(:exsss, {12356, 123_534, 345_345})

      room = Room.reserve("test-room") |> Room.start(4)
      state = Root.new(room, ["adhiraj", "krys", "aman", "farah"])

      %{state: state}
    end

    test "passing an affinity card should increase player's clout", %{state: state} do
      sets = state.deck.available_cards
      type = [type: :affinity, veracity: true, tgb: 0, target: :skub]
      card_id = Deck.draw_card(sets, type)

      IO.inspect(card_id)
    end
  end

  @tag timeout: :infinity
  test "temp" do
    :rand.seed(:exsss, {12356, 123_534, 345_345})
    store = StoreFixtures.new_store()
    store = StoreFixtures.set_chaos(store, 4)

    %{adhiraj: adhiraj, aman: aman, farah: farah, krys: krys} =
      StoreFixtures.player_by_names(store)

    # draw card of a certain type(?)

    Change.apply_change(store.players[aman.id], Options.change_clout(2))

    # IO.inspect(store.round)
    # IO.inspect(store.turn)
    # IO.inspect(store.players)
    # IO.inspect(store.room)
  end
end
