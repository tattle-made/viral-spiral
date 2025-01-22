defmodule ViralSpiral.Room.Actions do
  @moduledoc """
  Instances of Action triggered by a Player or Game Engine .
  """
  alias ViralSpiral.Room.Actions.Player.TurnToFake
  alias ViralSpiral.Canon.Card.Sparse
  alias ViralSpiral.Room.Action
  alias ViralSpiral.Entity.Turn
  import Ecto.Changeset

  def draw_card(draw_type) do
    %Action{type: :draw_card, payload: %{draw_type: draw_type}}
  end

  # @spec pass_card(String.t(), String.t(), String.t() | list(String.t())) :: Action.t()
  def pass_card(card, veracity, from, to) when is_bitstring(to) or is_list(to) do
    %Action{
      type: :pass_card,
      payload: %{
        card: card,
        veracity: veracity,
        player: from,
        target: to
      }
    }
  end

  def pass_card(%{"card" => card, "veracity" => veracity, "from" => from, "to" => to}) do
    pass_card(card, veracity, from, to)
  end

  def keep_card(card, from) do
    %Action{
      type: :keep_card,
      payload: %{
        card: card,
        player: from
      }
    }
  end

  def keep_card(%{"card" => card, "from" => from}) do
    keep_card(card, from)
  end

  def discard_card(card, from) do
    %Action{
      type: :discard_card,
      payload: %{
        card: card,
        player: from
      }
    }
  end

  def discard_card(%{"card" => card, "from" => from}) do
    discard_card(card, from)
  end

  def view_source(player_id, card_id, card_veracity) do
    %Action{
      type: :view_source,
      payload: %{
        player_id: player_id,
        card_id: card_id,
        card_veracity: card_veracity
      }
    }
  end

  def hide_source(player_id, card_id, card_veracity) do
    %Action{
      type: :hide_source,
      payload: %{
        player_id: player_id,
        card_id: card_id,
        card_veracity: card_veracity
      }
    }
  end

  def mark_card_as_fake(from, %Sparse{} = card, %Turn{} = turn) do
    %Action{
      type: :mark_card_as_fake,
      payload: %{
        from: from,
        card: card,
        turn: turn
      }
    }
  end

  @doc """
  Creates a valid Action for turn to fake power from user message
  """
  @spec turn_to_fake(map()) :: Action.t()
  def turn_to_fake(attrs) do
    action =
      %TurnToFake{}
      |> TurnToFake.changeset(attrs)
      |> apply_changes()

    %Action{
      type: :turn_card_to_fake,
      payload: action
    }
  end
end
