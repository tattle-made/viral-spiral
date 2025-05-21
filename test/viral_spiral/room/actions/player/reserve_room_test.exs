defmodule ViralSpiral.Room.Actions.Player.ReserveRoomTest do
  alias ViralSpiral.Room.Actions.Player.ReserveRoom
  use ExUnit.Case

  @valid_attrs %{
    "player_name" => "adhiraj"
  }

  test "validation" do
    changeset =
      %ReserveRoom{}
      |> ReserveRoom.changeset(@valid_attrs)

    assert changeset.valid? == true
  end
end
