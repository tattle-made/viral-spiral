defmodule ViralSpiral.Entity.PowerCancelPlayerTest do
  alias ViralSpiral.Entity.PowerCancelPlayer.Changes.{InitiateCancel, VoteCancel, ResetCancel}
  alias ViralSpiral.Entity.Change
  alias ViralSpiral.Entity.PowerCancelPlayer
  import ViralSpiral.Entity.PowerCancelPlayer
  use ExUnit.Case

  describe "entity" do
    test "happy path" do
      power = %PowerCancelPlayer{}
      assert power.state == :idle

      power =
        power
        |> start_vote("player_abc", "player_mno", :cat)
        |> allowed_voters(["player_def", "player_ghi"])

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

      # power = power |> reset()
      # assert power.state == :idle
      # assert length(power.votes) == 0
    end
  end

  test "changes" do
    power = %PowerCancelPlayer{}

    power =
      Change.change(power, %InitiateCancel{
        from_id: "player_abc",
        to_id: "player_def",
        affinity: :cat,
        allowed_voters: ["player_ghi", "player_jkl"]
      })

    power =
      Change.change(power, %VoteCancel{from_id: "player_ghi", vote: true})
      |> Change.change(%VoteCancel{from_id: "player_jkl", vote: true})

    assert power.state == :done
    assert power.result == true

    power = Change.change(power, %ResetCancel{})
    assert power.state == :idle

    power = %PowerCancelPlayer{}

    power =
      Change.change(power, %InitiateCancel{
        from_id: "player_abc",
        to_id: "player_def",
        affinity: :cat,
        allowed_voters: ["player_ghi", "player_jkl"]
      })

    power =
      Change.change(power, %VoteCancel{from_id: "player_ghi", vote: true})
      |> Change.change(%VoteCancel{from_id: "player_jkl", vote: false})

    assert power.state == :done
    assert power.result == false
  end
end
