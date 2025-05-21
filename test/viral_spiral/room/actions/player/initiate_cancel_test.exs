defmodule ViralSpiral.Room.Actions.Player.CancelPlayerInitiateTest do
  alias ViralSpiral.Room.Actions.Player.CancelPlayerInitiate
  use ExUnit.Case

  @valid_attr %{
    "from" => "player_abc",
    "target" => "player_def",
    "affinity" => "cat"
  }

  @invaid_attr %{
    "from" => "player_abc",
    "target" => "player_def",
    "affinity" => "Cat"
  }

  test "validation" do
    changeset =
      %CancelPlayerInitiate{}
      |> CancelPlayerInitiate.changeset(@valid_attr)

    assert changeset.valid? == true

    changeset =
      %CancelPlayerInitiate{}
      |> CancelPlayerInitiate.changeset(@invaid_attr)

    assert changeset.valid? == false
  end
end
