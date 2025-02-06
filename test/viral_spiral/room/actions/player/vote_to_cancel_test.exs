defmodule ViralSpiral.Room.Actions.Player.VoteToCancelTest do
  alias ViralSpiral.Room.Actions.Player.VoteToCancel
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
      %VoteToCancel{}
      |> VoteToCancel.changeset(@valid_attr)

    assert changeset.valid? == true

    changeset =
      %VoteToCancel{}
      |> VoteToCancel.changeset(@invalid_attr)

    assert changeset.valid? == false
  end
end
