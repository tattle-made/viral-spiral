defmodule ViralSpiral.Game.PlayerTest do
  alias ViralSpiral.Entity.Player.Changes.RemoveActiveCard
  alias ViralSpiral.Entity.Player.Changes.AddActiveCard
  alias ViralSpiral.Canon.Card.Sparse
  alias ViralSpiral.Entity.Player.Changes.AddToHand
  alias ViralSpiral.Entity.Player.Changes.Bias
  alias ViralSpiral.Entity.Player.Changes.Affinity
  alias ViralSpiral.Entity.Player.Changes.Clout
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
      player = Change.apply_change(player, %Clout{offset: 4})
      assert player.clout == 4
    end

    test "change affinity", %{player: player} do
      player = Change.apply_change(player, %Affinity{target: :skub, offset: 2})
      assert player.affinities.skub == 2
    end

    test "change bias", %{player: player} do
      player = Change.apply_change(player, %Bias{target: :yellow, offset: 1})
      assert player.biases.yellow == 1
    end

    test "add card to hand", %{player: player} do
      player =
        Change.apply_change(player, %AddToHand{card: %Sparse{id: "card_23b2323", veracity: false}})

      assert length(player.hand) == 1
      assert hd(player.hand) == "card_23b2323"
    end

    test "active cards", %{player: player} do
      card_a = %Sparse{id: "card_29323", veracity: true}
      card_b = %Sparse{id: "card_84843", veracity: false}

      player = Change.apply_change(player, %AddActiveCard{card: card_a})
      assert player.active_cards == [card_a]

      player = Change.apply_change(player, %AddActiveCard{card: card_b})
      assert player.active_cards == [card_a, card_b]

      player = Change.apply_change(player, %RemoveActiveCard{card: card_b})
      assert player.active_cards == [card_a]

      player = Change.apply_change(player, %RemoveActiveCard{card: card_a})
      assert player.active_cards == []
    end
  end
end
