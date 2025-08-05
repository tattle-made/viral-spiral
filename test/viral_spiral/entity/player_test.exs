defmodule ViralSpiral.Game.PlayerTest do
  alias ViralSpiral.Entity.Player.Changes.RemoveFromHand
  alias ViralSpiral.Entity.Player.Changes.CloseArticle
  alias ViralSpiral.Entity.Player.Changes.ViewArticle
  alias ViralSpiral.Canon.Article
  alias ViralSpiral.Entity.Player.Changes.RemoveActiveCard
  alias ViralSpiral.Entity.Player.Changes.AddActiveCard
  alias ViralSpiral.Canon.Card.Sparse
  alias ViralSpiral.Entity.Player.Changes.AddToHand
  alias ViralSpiral.Entity.Player.Changes.Bias
  alias ViralSpiral.Entity.Player.Changes.Affinity
  alias ViralSpiral.Entity.Player.Changes.Clout
  alias ViralSpiral.Entity.Player
  alias ViralSpiral.Entity.Change
  use ExUnit.Case

  # test "create player from room config" do
  #   room = Room.reserve("hello") |> Room.start(4)

  #   player =
  #     Factory.new_player_for_room(room)
  #     |> Player.set_name("adhiraj")

  #   assert player.name == "adhiraj"
  # end

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

      player = Player.new(attrs)
      assert %Player{biases: biases} = player
      assert biases.blue == 0
    end

    test "new/1 exception" do
      attrs = %{
        identity: :red,
        affinities: [:sock, :cow],
        biases: [:blue, :yellow]
      }

      assert_raise RuntimeError, "Invalid parameters were passed while creating a Player", fn ->
        Player.new(attrs)
      end
    end

    test "viralspiral_target_bias/2" do
      attrs = %{
        identity: :red,
        affinities: [:sock, :houseboat],
        biases: [:blue, :yellow]
      }

      player = Player.new(attrs)

      player = %{player | biases: %{blue: 6, yellow: 2}}
      target_bias = Player.viralspiral_target_bias(player, 5)
      assert target_bias == :blue

      player = %{player | biases: %{blue: 2, yellow: 2}}
      target_bias = Player.viralspiral_target_bias(player, 5)
      assert target_bias == nil

      player = %{player | biases: %{blue: 8, yellow: 8}}
      target_bias = Player.viralspiral_target_bias(player, 5)
      assert target_bias == :blue or target_bias == :yellow
    end
  end

  describe "changes" do
    setup do
      player = %Player{
        id: "player_abc",
        identity: :blue,
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
      player = Change.change(player, %Clout{offset: 4})
      assert player.clout == 4

      player = Change.change(player, %Clout{offset: -2})
      assert player.clout == 2
    end

    test "change affinity", %{player: player} do
      player = Change.change(player, %Affinity{target: :skub, offset: 2})
      assert player.affinities.skub == 2

      player = Change.change(player, %Affinity{target: :skub, offset: -1})
      assert player.affinities.skub == 1
    end

    test "change bias", %{player: player} do
      player = Change.change(player, %Bias{target: :yellow, offset: 1})
      assert player.biases.yellow == 3

      player = Change.change(player, %Bias{target: :yellow, offset: -3})
      assert player.biases.yellow == 0
    end

    test "add card to hand", %{player: player} do
      card = %Sparse{id: "card_23b2323", veracity: false}
      player = Change.change(player, %AddToHand{card: card})

      assert length(player.hand) == 1
      assert hd(player.hand) == card
    end

    test "remove card from hand", %{player: player} do
      card = %Sparse{id: "card_3234234", veracity: true}
      player = %{player | hand: [card]}

      assert length(player.hand) == 1

      player = Change.change(player, %RemoveFromHand{card: card})
      assert length(player.hand) == 0
    end

    test "active cards", %{player: player} do
      card_a = %Sparse{id: "card_29323", veracity: true}
      card_b = %Sparse{id: "card_84843", veracity: false}

      player = Change.change(player, %AddActiveCard{card: card_a})
      assert player.active_cards == [card_a]

      player = Change.change(player, %AddActiveCard{card: card_b})
      assert player.active_cards == [card_a, card_b]

      player = Change.change(player, %RemoveActiveCard{card: card_b})
      assert player.active_cards == [card_a]

      player = Change.change(player, %RemoveActiveCard{card: card_a})
      assert player.active_cards == []
    end

    test "view and hide source", %{player: player} do
      card_a = %Sparse{id: "card_29323", veracity: true}
      article_a = %Article{card_id: "card_29323", veracity: true}
      player = Change.change(player, %ViewArticle{card: card_a, article: article_a})
      assert player.open_articles[card_a] == article_a

      card_b = %Sparse{id: "card_6866", veracity: true}
      article_b = %Article{card_id: "card_6866", veracity: true}
      player = Change.change(player, %ViewArticle{card: card_b, article: article_b})
      assert player.open_articles[card_b] == article_b

      assert Map.keys(player.open_articles) |> length() == 2
      player = Change.change(player, %CloseArticle{card: card_a})
      assert player.open_articles[card_a] == nil
      assert Map.keys(player.open_articles) |> length() == 1
    end
  end
end
