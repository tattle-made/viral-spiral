defmodule ViralSpiral.Room.Actions.Player.InitiateCancelTest do
  alias ViralSpiral.Room.Actions.Player.InitiateCancel
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
      %InitiateCancel{}
      |> InitiateCancel.changeset(@valid_attr)

    assert changeset.valid? == true

    changeset =
      %InitiateCancel{}
      |> InitiateCancel.changeset(@invaid_attr)

    assert changeset.valid? == false
  end
end
