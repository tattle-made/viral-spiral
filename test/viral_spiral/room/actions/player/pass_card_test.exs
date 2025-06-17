defmodule ViralSpiral.Room.Actions.Player.PassCardTest do
  require IEx
  alias ViralSpiral.Room.Actions.Player.PassCard
  use ExUnit.Case

  @valid_attrs %{
    "from_id" => "player_abc",
    "to_id" => "player_def",
    "card" => %{
      "id" => "card_oti",
      "veracity" => "true"
    }
  }

  @invalid_attrs %{
    "from_id" => "player_abc",
    "card" => %{
      "id" => "card_oti",
      "veracity" => "true"
    }
  }

  test "validation" do
    valid_changeset =
      %PassCard{}
      |> PassCard.changeset(@valid_attrs)

    assert valid_changeset.valid? == true

    invalid_changeset =
      %PassCard{}
      |> PassCard.changeset(@invalid_attrs)

    assert invalid_changeset.valid? == false
  end
end
