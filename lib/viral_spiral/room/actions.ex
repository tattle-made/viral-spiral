defmodule ViralSpiral.Room.Actions do
  @moduledoc """
  Instances of Action triggered by a Player or Game Engine .
  """
  alias ViralSpiral.Room.Action

  def draw_card() do
    %Action{type: :draw_card}
  end

  @spec pass_card(String.t(), String.t(), String.t() | list(String.t())) :: Action.t()
  def pass_card(card, from, to) when is_bitstring(to) or is_list(to) do
    %Action{
      type: :pass_card,
      payload: %{
        card: card,
        player: from,
        target: to
      }
    }
  end

  def pass_card(%{"card" => card, "from" => from, "to" => to}) do
    pass_card(card, from, to)
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
end
