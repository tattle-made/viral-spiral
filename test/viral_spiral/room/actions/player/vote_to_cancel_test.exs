defmodule ViralSpiral.Room.Actions.Player.CancelPlayerVoteTest do
  alias ViralSpiral.Room.Actions.Player.CancelPlayerVote
  use ExUnit.Case

  @valid_attr %{
    "player" => "player_abc",
    "vote" => "true"
  }

  @invalid_attr %{
    "player" => "player_abc",
    "vote" => "NaN"
  }

  test "validation" do
    changeset =
      %CancelPlayerVote{}
      |> CancelPlayerVote.changeset(@valid_attr)

    assert changeset.valid? == true

    changeset =
      %CancelPlayerVote{}
      |> CancelPlayerVote.changeset(@invalid_attr)

    assert changeset.valid? == false
  end
end
