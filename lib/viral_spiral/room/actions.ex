defmodule ViralSpiral.Room.Actions do
  @moduledoc """
  Instances of Action triggered by a Player or Game Engine .
  """

  alias ViralSpiral.Room.Actions.Player.ViralSpiralInitiate

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
      true -> apply_changes(changeset)
      false -> raise "Invalid Attributes"
    end
  end

  def join_room(attrs) do
    changeset = %JoinRoom{} |> JoinRoom.changeset(attrs)

    case changeset.valid? do
      true -> apply_changes(changeset)
      false -> raise "Invalid Attributes"
    end
  end

  def start_game() do
    %StartGame{}
  end

  def draw_card() do
    %DrawCard{}
  end

  def draw_card(attrs) do
    %DrawCard{card: attrs.card}
  end

  def pass_card(attrs) do
    changeset = %PassCard{} |> PassCard.changeset(attrs)

    case changeset.valid? do
      true -> apply_changes(changeset)
      false -> raise "Invalid Attributes"
    end
  end

  def keep_card(attrs) do
    changeset = %KeepCard{} |> KeepCard.changeset(attrs)

    case changeset.valid? do
      true -> apply_changes(changeset)
      false -> raise "Invalid Attributes"
    end
  end

  def discard_card(attrs) do
    changeset = %DiscardCard{} |> DiscardCard.changeset(attrs)

    case changeset.valid? do
      true -> apply_changes(changeset)
      false -> raise "Invalid Attributes"
    end
  end

  def view_source(attrs) do
    changeset = %ViewSource{} |> ViewSource.changeset(attrs)

    case changeset.valid? do
      true -> apply_changes(changeset)
      false -> raise "Invalid format of action view source"
    end
  end

  def hide_source(attrs) do
    changeset = %HideSource{} |> HideSource.changeset(attrs)

    case changeset.valid? do
      true -> apply_changes(changeset)
      false -> raise "Invalid attributes"
    end
  end

  def mark_card_as_fake(attrs) do
    changeset = %MarkAsFake{} |> MarkAsFake.changeset(attrs)

    case changeset.valid? do
      true -> apply_changes(changeset)
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
      true -> apply_changes(changeset)
      false -> raise "Invalid attributes"
    end
  end

  def initiate_cancel(attrs) do
    changeset = %CancelPlayerInitiate{} |> CancelPlayerInitiate.changeset(attrs)

    case changeset.valid? do
      true -> apply_changes(changeset)
      false -> raise "Invalid attributes"
    end
  end

  def vote_to_cancel(attrs) do
    changeset = %CancelPlayerVote{} |> CancelPlayerVote.changeset(attrs)

    case changeset.valid? do
      true -> apply_changes(changeset)
      false -> raise "Invalid attributes"
    end
  end

  def initiate_viralspiral(attrs) do
    changeset = %ViralSpiralInitiate{} |> ViralSpiralInitiate.changeset(attrs)

    case changeset.valid? do
      true -> apply_changes(changeset)
      false -> raise "Invalid attributes"
    end
  end

  def string_to_map(params) do
    params["value"]
    |> Jason.decode!()
  end
end
