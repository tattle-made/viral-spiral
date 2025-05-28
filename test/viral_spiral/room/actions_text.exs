defmodule ViralSpiral.Room.ActionsTest do
  use ExUnit.Case

  alias ViralSpiral.Room.Actions.Player.{
    ReserveRoom,
    JoinRoom,
    StartGame,
    KeepCard,
    PassCard,
    DiscardCard,
    MarkAsFake,
    ViewSource,
    CancelPlayerInitiate,
    CancelPlayerVote,
    TurnToFake,
    HideSource
  }

  alias ViralSpiral.Room.Actions.Engine.{
    DrawCard
  }

  alias ViralSpiral.Room.Actions

  test "reserve_room" do
    action = Actions.reserve_room(%{"player_name" => "adhiraj"})
    assert %ReserveRoom{} = action
  end

  test "join room" do
    action = Actions.join_room(%{"player_name" => "aman"})
    assert %JoinRoom{} = action
  end

  test "start game" do
    action = Actions.start_game()
    assert %StartGame{} = action
  end

  test "draw card" do
    action = Actions.draw_card()
    assert %DrawCard{} = action
  end

  test "pass card" do
    attrs = %{
      "from_id" => "player_abc",
      "to_id" => "player_def",
      "card" => %{
        "id" => "card_ags",
        "veracity" => "true"
      }
    }

    action = Actions.pass_card(attrs)
    assert %PassCard{} = action
  end

  test "keep card" do
    attrs = %{
      "from_id" => "player_abc",
      "card" => %{
        "id" => "card_ags",
        "veracity" => "true"
      }
    }

    action = Actions.keep_card(attrs)
    assert %KeepCard{} = action
  end

  test "discard card" do
    attrs = %{
      "from_id" => "player_abc",
      "card" => %{
        "id" => "card_ags",
        "veracity" => "true"
      }
    }

    action = Actions.discard_card(attrs)
    assert %DiscardCard{} = action
  end

  test "view source" do
    attrs = %{
      "from_id" => "player_abc",
      "card" => %{
        "id" => "card_ags",
        "veracity" => "true"
      }
    }

    action = Actions.view_source(attrs)
    assert %ViewSource{} = action
  end

  test "hide source" do
    attrs = %{
      "from_id" => "player_abc",
      "card" => %{
        "id" => "card_ags",
        "veracity" => "true"
      }
    }

    action = Actions.hide_source(attrs)
    assert %HideSource{} = action
  end

  test "mark as fake" do
    attrs = %{
      "from_id" => "player_abc",
      "card" => %{
        "id" => "card_ags",
        "veracity" => "true"
      }
    }

    action = Actions.mark_card_as_fake(attrs)
    assert %MarkAsFake{} = action
  end

  test "turn to fake" do
    attrs = %{
      "from_id" => "player_abc",
      "card" => %{
        "id" => "card_ags",
        "veracity" => "true"
      }
    }

    action = Actions.turn_to_fake(attrs)
    assert %TurnToFake{} = action
  end

  test "cancel player initiate" do
    attrs = %{
      "from_id" => "player_abc",
      "target_id" => "player_def",
      "affinity" => "cat"
    }

    action = Actions.initiate_cancel(attrs)
    assert %CancelPlayerInitiate{} = action
  end

  test "cancel player vote" do
    attrs = %{
      "from_id" => "player_abc",
      "vote" => "true"
    }

    action = Actions.vote_to_cancel(attrs)
    assert %CancelPlayerVote{} = action
  end
end
