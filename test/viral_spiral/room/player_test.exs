defmodule ViralSpiral.Game.PlayerTest do
  alias ViralSpiral.Gameplay.Factory
  alias ViralSpiral.GamePlay.Change.Options
  alias ViralSpiral.Room.State.Room
  alias ViralSpiral.Room.State.Player.ActiveCardDoesNotExist
  alias ViralSpiral.Room.State.Player.DuplicateActiveCardException
  alias ViralSpiral.Room.State.Player
  alias ViralSpiral.Room.State.Change
  use ExUnit.Case

  test "create player from room config" do
    room = Room.new(4)

    player =
      Factory.new_player_for_room(room)
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

  describe "changes" do
    setup do
      player = %Player{
        affinities: %{
          skub: 0,
          cat: 0
        },
        biases: %{
          red: 0,
          yellow: 2
        }
      }

      %{player: player}
    end

    test "change clout", %{player: player} do
      player = Change.apply_change(player, nil, Options.change_clout(4))
      assert player.clout == 4
    end

    test "change affinity", %{player: player} do
      player = Change.apply_change(player, nil, Options.change_affinity(:cat, 2))
      assert player.affinities.cat == 2
    end

    test "change bias", %{player: player} do
      player = Change.apply_change(player, nil, Options.change_bias(:yellow, -1))
      assert player.biases.yellow == 1
    end

    test "add card to hand", %{player: player} do
      player = Change.apply_change(player, nil, Options.add_to_hand("card_23b2323"))
      assert length(player.hand) == 1
      assert hd(player.hand) == "card_23b2323"
    end

    test "add_active_card", %{player: player} do
      player = Change.apply_change(player, nil, Options.add_to_active("card_29323"))
      assert player.active_cards == ["card_29323"]

      player = Change.apply_change(player, nil, Options.add_to_active("card_84843"))
      assert player.active_cards == ["card_29323", "card_84843"]
    end

    test "remove_active_card", %{player: player} do
      player =
        %{player | active_cards: ["card_29323", "card_84843"]}
        |> Change.apply_change(nil, Options.remove_active("card_29323"))

      assert player.active_cards == ["card_84843"]

      player = Change.apply_change(player, nil, Options.remove_active("card_84843"))

      assert player.active_cards == []
    end
  end
end
