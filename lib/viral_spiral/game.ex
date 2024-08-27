defmodule ViralSpiral.Game do
  @moduledoc """
  Context for Game
  """
  alias ViralSpiral.Canon.Card.Share
  alias ViralSpiral.Game.State
  alias ViralSpiral.Game.Score.Player
  alias ViralSpiral.Game.Player
  alias ViralSpiral.Deck.Card
  alias ViralSpiral.Game.Room

  @spec create_room(String.t()) :: Room.t()
  def create_room(_name) do
  end

  @spec join_room(String.t(), String.t()) :: Room.t()
  def join_room(_name, _password) do
  end

  @doc """
  Pass a card from one player to another.
  """
  # @spec pass_card(Player.t(), Card.t()) :: list(Change.t())
  def pass_card(state, card, %Player{} = from, %Player{} = to) do
    changes = Share.pass(card, state, from, to)
    State.apply_changes(state, changes)
    # changes =
    #   case card.type do
    #     :affinity -> [{state.player_scores[from.id], [type: :inc, target: :affinity, count: 1]}]
    #   end
  end

  # def keep_card(player) do
  #   changes = Share.pass(card, state, from, to)
  #   State.apply_changes(state, changes)
  # end

  # def discard_card(player) do
  #   changes = Share.pass(card, state)
  #   State.apply_changes(state, changes)
  # end

  def turn_to_fake(_player, _card) do
  end

  def cancel_player(_player, _target) do
  end

  def cancel_player_vote(_player, _target) do
  end

  def viral_spiral(_player, _targets) do
  end
end
