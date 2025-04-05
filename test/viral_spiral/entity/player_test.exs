defmodule ViralSpiral.Game.PlayerTest do
  alias ViralSpiral.Room.Factory
  alias ViralSpiral.Room.ChangeDescriptions
  alias ViralSpiral.Entity.Room
  alias ViralSpiral.Entity.Player.ActiveCardDoesNotExist
  alias ViralSpiral.Entity.Player.DuplicateActiveCardException
  alias ViralSpiral.Entity.Player
  alias ViralSpiral.Entity.Change
  use ExUnit.Case

  test "create player from room config" do
    room = Room.reserve("hello") |> Room.start(4)

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

    test "new/1" do
      attrs = %{
        id: "temp_id",
        name: "temp_name",
        identity: :red,
        affinities: [:sock, :cat],
        biases: [:blue, :yellow]
      }

      Player.new(attrs) |> IO.inspect()
    end

    test "new/1 exceptions" do
      attrs = %{
        identity: :red,
        affinities: [:sock, :cow],
        biases: [:blue, :yellow]
      }

      assert_raise RuntimeError, "Invalid parameters were passed while creating a Player", fn ->
        Player.new(attrs)
      end
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
      player = Change.apply_change(player, ChangeDescriptions.change_clout(4))
      assert player.clout == 4
    end

    test "change affinity", %{player: player} do
      player = Change.apply_change(player, ChangeDescriptions.change_affinity(:cat, 2))
      assert player.affinities.cat == 2
    end

    test "change bias", %{player: player} do
      player = Change.apply_change(player, ChangeDescriptions.change_bias(:yellow, -1))
      assert player.biases.yellow == 1
    end

    test "add card to hand", %{player: player} do
      player = Change.apply_change(player, ChangeDescriptions.add_to_hand("card_23b2323"))
      assert length(player.hand) == 1
      assert hd(player.hand) == "card_23b2323"
    end

    test "add_active_card", %{player: player} do
      player = Change.apply_change(player, ChangeDescriptions.add_to_active("card_29323"))
      assert player.active_cards == ["card_29323"]

      player = Change.apply_change(player, ChangeDescriptions.add_to_active("card_84843"))
      assert player.active_cards == ["card_29323", "card_84843"]
    end

    test "remove_active_card", %{player: player} do
      player =
        %{player | active_cards: ["card_29323", "card_84843"]}
        |> Change.apply_change(ChangeDescriptions.remove_active("card_29323"))

      assert player.active_cards == ["card_84843"]

      player = Change.apply_change(player, ChangeDescriptions.remove_active("card_84843"))

      assert player.active_cards == []
    end
  end
end
