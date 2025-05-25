defmodule ViralSpiral.Entity.PowerViralSpiralTest do
  alias ViralSpiral.Entity.Change
  alias ViralSpiral.Canon.Card.Sparse
  alias ViralSpiral.Entity.Turn
  alias ViralSpiral.Entity.PowerViralSpiral
  use ExUnit.Case

  @tag :skip
  describe "entity" do
    setup do
      power = %PowerViralSpiral{
        turns: [
          %Turn{
            card: %Sparse{id: "card_pqr", veracity: true},
            current: "player_abc",
            pass_to: ["player_def", "player_ghi"]
          },
          %Turn{
            card: %Sparse{id: "card_pqr", veracity: true},
            current: "player_jkl",
            pass_to: ["player_def", "player_ghi"]
          }
        ]
      }

      %{power: power}
    end

    test "new", %{power: power} do
      assert power.turns |> length() == 2
      assert PowerViralSpiral.get_turn(power, "player_jkl").current == "player_jkl"
      assert PowerViralSpiral.get_turn(power, "player_abc").current == "player_abc"

      assert PowerViralSpiral.pass_to(power, "player_jkl") ==
               ["player_def", "player_ghi"]
    end
  end

  # @tag :skip
  # describe "changes" do
  #   setup do
  #     power = %PowerViralSpiral{
  #       turns: [
  #         %Turn{
  #           card: %Sparse{id: "card_pqr", veracity: true},
  #           current: "player_abc",
  #           pass_to: ["player_def", "player_ghi"]
  #         },
  #         %Turn{
  #           card: %Sparse{id: "card_pqr", veracity: true},
  #           current: "player_jkl",
  #           pass_to: ["player_def", "player_ghi"]
  #         }
  #       ]
  #     }

  #     %{power: power}
  #   end

  #   test "reset", %{power: power} do
  #     power = Change.apply_change(power, ChangeDescriptions.PowerViralSpiral.reset())
  #     assert power == nil
  #   end

  #   test "pass to someone", %{power: power} do
  #     power =
  #       Change.apply_change(
  #         power,
  #         ChangeDescriptions.PowerViralSpiral.pass("player_jkl", "player_ghi")
  #       )

  #     assert PowerViralSpiral.get_turn(power, "player_ghi").current == "player_ghi"
  #     assert PowerViralSpiral.pass_to(power, "player_ghi") == ["player_def"]
  #     assert PowerViralSpiral.pass_to(power, "player_abc") == ["player_def"]

  #     power =
  #       Change.apply_change(
  #         power,
  #         ChangeDescriptions.PowerViralSpiral.pass("player_abc", "player_def")
  #       )

  #     assert power == nil
  #   end
  # end
end
