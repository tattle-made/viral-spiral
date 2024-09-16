defmodule ViralSpiral.Game.PlayerTest do
  alias ViralSpiral.Room.RoomConfig
  alias ViralSpiral.Room.State.Player.ActiveCardDoesNotExist
  alias ViralSpiral.Room.State.Player.DuplicateActiveCardException
  alias ViralSpiral.Room.State.Player
  alias ViralSpiral.Room.State.Change
  use ExUnit.Case

  test "create player from room config" do
    room_config = RoomConfig.new(4)

    player =
      Player.new(room_config)
      |> Player.set_name("adhiraj")

    assert player.name == "adhiraj"
  end

  describe "struct operations" do
    setup do
      player = %Player{}

      %{player: player}
    end

    test "add and remove cards", %{player: player} do
      player =
        player
        |> Player.add_active_card("card_293848")
        |> Player.add_active_card("card_238422")

      assert player.active_cards == ["card_293848", "card_238422"]

      player = Player.remove_active_card(player, "card_293848")
      assert player.active_cards == ["card_238422"]
    end

    test "player should not be able to hold same card twice", %{player: player} do
      assert_raise DuplicateActiveCardException, fn ->
        player
        |> Player.add_active_card("card_293848")
        |> Player.add_active_card("card_293848")
      end
    end

    test "raise when trying to remove a card that is not an active card", %{player: player} do
      assert_raise ActiveCardDoesNotExist, fn ->
        player
        |> Player.remove_active_card("card_39293")
      end

      assert_raise ActiveCardDoesNotExist, fn ->
        player
        |> Player.add_active_card("card_232323")
        |> Player.remove_active_card("card_392323")
      end
    end
  end

  describe "Change implementation" do
    setup do
      player = %Player{}

      %{player: player}
    end

    test "add_active_card", %{player: player} do
      player = Change.apply_change(player, nil, type: :add_active_card, card_id: "card_29323")
      assert player.active_cards == ["card_29323"]

      player = Change.apply_change(player, nil, type: :add_active_card, card_id: "card_84843")
      assert player.active_cards == ["card_29323", "card_84843"]
    end

    test "remove_active_card", %{player: player} do
      player =
        player
        |> Player.add_active_card("card_29323")
        |> Player.add_active_card("card_84843")

      player = Change.apply_change(player, nil, type: :remove_active_card, card_id: "card_29323")
      player = Change.apply_change(player, nil, type: :remove_active_card, card_id: "card_84843")
      assert player.active_cards == []
    end
  end
end
