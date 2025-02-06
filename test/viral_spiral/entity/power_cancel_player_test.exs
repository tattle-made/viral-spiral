defmodule ViralSpiral.Entity.PowerCancelPlayerTest do
  alias ViralSpiral.Entity.PowerCancelPlayer
  import ViralSpiral.Entity.PowerCancelPlayer
  use ExUnit.Case

  describe "entity" do
    test "happy path" do
      power = %PowerCancelPlayer{}
      assert power.state == :idle

      power = power |> start_vote("player_abc", "player_mno", :cat)
      assert power.state == :waiting

      power =
        power
        |> vote("player_def", true)
        |> vote("player_ghi", true)

      assert power.votes |> length() == 2

      power = power |> vote("player_jkl", false, done: true)
      assert power.votes |> length() == 3
      assert power.state == :done

      power = power |> put_result()
      assert power.result == true

      IO.inspect(power)

      power = power |> reset()
      assert power.state == :idle
      assert length(power.votes) == 0
    end
  end

  describe "changes" do
    setup do
      %{}
    end

    test "initiate" do
    end

    test "vote" do
    end
  end
end
