defmodule ViralSpiral.Room.ChangeOptions do
  @moduledoc """
  Commonly used change options put behind user friendly names.
  """

  def change_clout(offset), do: [type: :clout, offset: offset]
  def change_affinity(target, offset), do: [type: :affinity, target: target, offset: offset]
  def change_bias(target, offset), do: [type: :bias, target: target, offset: offset]
  def add_to_hand(card_id), do: [type: :add_to_hand, card_id: card_id]
  def add_to_active(card_id), do: [type: :add_active_card, card_id: card_id]
  def remove_active(card_id), do: [type: :remove_active_card, card_id: card_id]

  def change_chaos(offset), do: [type: :chaos_countdown, offset: offset]

  def new_round(), do: []
  def next_round(), do: []
  def new_turn(), do: []
  def pass_turn_to(player) when is_binary(player), do: []
  def pass_turn_to(players) when is_list(players), do: []

  def draw_new_card(), do: []
  def discard_card(), do: []

  @doc """

  """
  def remove_card(draw_type, card_id),
    do: [type: :remove_card, draw_type: draw_type, card: card_id]
end
