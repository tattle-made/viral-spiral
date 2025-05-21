defmodule ViralSpiral.Room.ActionsTest do
  use ExUnit.Case

  alias ViralSpiral.Room.Actions.Player.TurnToFake
  alias ViralSpiral.Room.Actions.Player.HideSource

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
    CancelPlayerVote
  }

  alias ViralSpiral.Room.Actions.Engine.{
    DrawCard
  }

  alias ViralSpiral.Room.Action
  alias ViralSpiral.Room.Actions

  test "reserve_room" do
    action = Actions.reserve_room(%{"player_name" => "adhiraj"})
    assert %Action{type: :reserve_room, payload: %ReserveRoom{}} = action
  end

  test "join room" do
    action = Actions.join_room(%{"player_name" => "aman"})
    assert %Action{type: :join_room, payload: %JoinRoom{}} = action
  end

  test "start game" do
    action = Actions.start_game()
    assert %Action{type: :start_game, payload: %StartGame{}} = action
  end

  test "draw card" do
    action = Actions.draw_card()
    assert %Action{type: :draw_card, payload: %DrawCard{}} = action
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
    assert %Action{type: :pass_card, payload: %PassCard{}} = action
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
    assert %Action{type: :keep_card, payload: %KeepCard{}} = action
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
    assert %Action{type: :discard_card, payload: %DiscardCard{}} = action
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
    assert %Action{type: :view_source, payload: %ViewSource{}} = action
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
    assert %Action{type: :hide_source, payload: %HideSource{}} = action
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
    assert %Action{type: :mark_as_fake, payload: %MarkAsFake{}} = action
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
    assert %Action{type: :turn_to_fake, payload: %TurnToFake{}} = action
  end

  test "cancel player initiate" do
    attrs = %{
      "from_id" => "player_abc",
      "target_id" => "player_def",
      "affinity" => "cat"
    }

    action = Actions.initiate_cancel(attrs)
    assert %Action{type: :cancel_player_initiate, payload: %CancelPlayerInitiate{}} = action
  end

  test "cancel player vote" do
    attrs = %{
      "from_id" => "player_abc",
      "vote" => "true"
    }

    action = Actions.vote_to_cancel(attrs)
    assert %Action{type: :cancel_player_vote, payload: %CancelPlayerVote{}} = action
  end
end
