defmodule ViralSpiral.Game do
  alias ViralSpiral.Game.Room
  alias ViralSpiral.Game.State

  @spec create_room(String.t()) :: Room.t()
  def create_room(name) do
  end

  @spec join_room(String.t(), String.t()) :: Room.t()
  def join_room(name, password) do
  end

  def pass_card(state, player, to) do
  end

  def keep_card(player) do
  end

  def discard_card(player) do
  end

  def turn_to_fake(player, card) do
  end

  def cancel_player(player, target) do
  end

  def viral_spiral(player, targets) do
  end
end
