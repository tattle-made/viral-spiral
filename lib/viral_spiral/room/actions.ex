defmodule ViralSpiral.Room.Actions do
  @moduledoc """
  Instances of Action triggered by a Player or Game Engine .
  """

  alias ViralSpiral.Room.Actions.Player.{
    ReserveRoom,
    JoinRoom,
    StartGame,
    KeepCard,
    PassCard,
    DiscardCard,
    MarkAsFake,
    TurnToFake,
    ViewSource,
    CancelPlayerInitiate,
    CancelPlayerVote,
    HideSource
  }

  alias ViralSpiral.Room.Actions.Engine.{
    DrawCard
  }

  alias ViralSpiral.Room.Action

  import Ecto.Changeset

  def reserve_room(attrs) do
    changeset = %ReserveRoom{} |> ReserveRoom.changeset(attrs)

    case changeset.valid? do
      true -> %Action{type: :reserve_room, payload: apply_changes(changeset)}
      false -> raise "Invalid Attributes"
    end
  end

  def join_room(attrs) do
    changeset = %JoinRoom{} |> JoinRoom.changeset(attrs)

    case changeset.valid? do
      true -> %Action{type: :join_room, payload: apply_changes(changeset)}
      false -> raise "Invalid Attributes"
    end
  end

  def start_game() do
    %Action{type: :start_game, payload: %StartGame{}}
  end

  def draw_card() do
    %Action{type: :draw_card, payload: %DrawCard{}}
  end

  def pass_card(attrs) do
    changeset = %PassCard{} |> PassCard.changeset(attrs)

    case changeset.valid? do
      true -> %Action{type: :pass_card, payload: apply_changes(changeset)}
      false -> raise "Invalid Attributes"
    end
  end

  def keep_card(attrs) do
    changeset = %KeepCard{} |> KeepCard.changeset(attrs)

    case changeset.valid? do
      true -> %Action{type: :keep_card, payload: apply_changes(changeset)}
      false -> raise "Invalid Attributes"
    end
  end

  def discard_card(attrs) do
    changeset = %DiscardCard{} |> DiscardCard.changeset(attrs)

    case changeset.valid? do
      true -> %Action{type: :discard_card, payload: apply_changes(changeset)}
      false -> raise "Invalid Attributes"
    end
  end

  def view_source(attrs) do
    changeset = %ViewSource{} |> ViewSource.changeset(attrs)

    case changeset.valid? do
      true -> %Action{type: :view_source, payload: apply_changes(changeset)}
      false -> raise "Invalid format of action view source"
    end
  end

  def hide_source(attrs) do
    changeset = %HideSource{} |> HideSource.changeset(attrs)

    case changeset.valid? do
      true -> %Action{type: :hide_source, payload: apply_changes(changeset)}
      false -> raise "Invalid attributes"
    end
  end

  def mark_card_as_fake(attrs) do
    changeset = %MarkAsFake{} |> MarkAsFake.changeset(attrs)

    case changeset.valid? do
      true -> %Action{type: :mark_as_fake, payload: apply_changes(changeset)}
      false -> raise "Invalid attributes"
    end
  end

  @doc """
  Creates a valid Action for turn to fake power from user message
  """
  @spec turn_to_fake(map()) :: Action.t()
  def turn_to_fake(attrs) do
    changeset = %TurnToFake{} |> TurnToFake.changeset(attrs)

    case changeset.valid? do
      true -> %Action{type: :turn_to_fake, payload: apply_changes(changeset)}
      false -> raise "Invalid attributes"
    end
  end

  def initiate_cancel(attrs) do
    changeset = %CancelPlayerInitiate{} |> CancelPlayerInitiate.changeset(attrs)

    case changeset.valid? do
      true -> %Action{type: :cancel_player_initiate, payload: apply_changes(changeset)}
      false -> raise "Invalid attributes"
    end
  end

  def vote_to_cancel(attrs) do
    changeset = %CancelPlayerVote{} |> CancelPlayerVote.changeset(attrs)

    case changeset.valid? do
      true -> %Action{type: :cancel_player_vote, payload: apply_changes(changeset)}
      false -> raise "Invalid attributes"
    end
  end
end
