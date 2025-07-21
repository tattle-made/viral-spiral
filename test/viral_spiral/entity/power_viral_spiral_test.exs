defmodule ViralSpiral.Entity.PowerViralSpiralTest do
  alias ViralSpiral.Canon.Card.Sparse
  alias ViralSpiral.Entity.Change
  alias ViralSpiral.Entity.Turn
  alias ViralSpiral.Entity.PowerViralSpiral
  alias ViralSpiral.Entity.PowerViralSpiral.Changes.InitiateViralSpiral
  use ExUnit.Case

  describe "entity" do
    setup do
      entity =
        PowerViralSpiral.new(
          "player_abc",
          ["player_def", "player_ghi"],
          Sparse.new("card_abc", true)
        )

      %{entity: entity}
    end

    test "new/3" do
      entity =
        PowerViralSpiral.new(
          "player_abc",
          ["player_def", "player_ghi"],
          Sparse.new("card_abc", true)
        )

      assert entity.status == :active
      assert entity.from == "player_abc"
      assert entity.to == ["player_def", "player_ghi"]
      assert entity.card.id == "card_abc"
      assert entity.card.veracity == true
    end
  end

  describe "changes" do
    setup do
      entity = PowerViralSpiral.skeleton()
      %{entity: entity}
    end

    test "InitiateViralSpiral", %{entity: entity} do
      entity =
        entity
        |> Change.change(%InitiateViralSpiral{
          from_id: "player_abc",
          to_id: ["player_def", "player_ghi"],
          card: Sparse.new("card_asdf", true)
        })

      assert entity.status == :active
      assert entity.from == "player_abc"
      assert entity.to == ["player_def", "player_ghi"]
      assert entity.card.id == "card_asdf"
      assert entity.card.veracity == true
    end

    test "PassViralSpiral", %{entity: entity} do
    end
  end
end
