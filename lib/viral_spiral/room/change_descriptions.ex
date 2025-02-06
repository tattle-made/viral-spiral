defmodule ViralSpiral.Room.ChangeDescriptions do
  @moduledoc """
  Commonly used change options put behind user friendly names.
  """

  def change_clout(offset), do: [type: :clout, offset: offset]
  def change_affinity(target, offset), do: [type: :affinity, target: target, offset: offset]
  def change_bias(target, offset), do: [type: :bias, target: target, offset: offset]
  def add_to_hand(card_id), do: [type: :add_to_hand, card_id: card_id]

  def add_to_active(card_id, veracity),
    do: [type: :add_active_card, card_id: card_id, veracity: veracity]

  def remove_active(card_id, veracity),
    do: [type: :remove_active_card, card_id: card_id, veracity: veracity]

  def change_chaos(offset), do: [type: :chaos_countdown, offset: offset]

  def new_round(), do: []
  def next_round(), do: [type: :next]
  def skip_player(player_id), do: [type: :skip, player_id: player_id]
  def new_turn(), do: []
  def pass_turn_to(player_id) when is_binary(player_id), do: [type: :next, target: player_id]
  def pass_turn_to(players) when is_list(players), do: []

  def draw_new_card(), do: []
  def discard_card(), do: []

  def set_article(card, article), do: [type: :set_article, card: card, article: article]
  def reset_article(card), do: [type: :reset_article, card: card]

  @doc """

  """
  def remove_card(draw_type, card),
    do: [type: :remove_card, draw_type: draw_type, card_in_set: card]

  defmodule PowerViralSpiral do
    alias ViralSpiral.Canon.Card.Sparse

    def set(players, %Sparse{} = card) do
      [type: :set, players: players, card: card]
    end

    def reset() do
      [type: :reset]
    end

    def pass(from, to) do
      [type: :pass, from: from, to: to]
    end
  end

  defmodule PowerCancelPlayer do
    def initiate(from, target, affinity) do
      Keyword.new()
      |> Keyword.put(:type, :initiate)
      |> Keyword.put(:from, from)
      |> Keyword.put(:target, target)
      |> Keyword.put(:affinity, affinity)
    end

    def vote(from, vote, opts) do
      Keyword.new()
      |> Keyword.put(:type, :vote)
      |> Keyword.put(:from, from)
      |> Keyword.put(:vote, vote)
      |> Keyword.put(:opts, opts)
    end
  end

  defmodule Room do
    def join(player_name) do
      [type: :join, player_name: player_name]
    end
  end

  def turn_to_fake(sparse_card) do
    [type: :turn_card_to_fake, card: sparse_card]
  end
end
