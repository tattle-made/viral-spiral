defmodule ViralSpiral.Game do
  alias ViralSpiral.Game.Room

  @spec create_room(String.t()) :: Room.t()
  def create_room(_name) do
  end

  @spec join_room(String.t(), String.t()) :: Room.t()
  def join_room(_name, _password) do
  end

  def pass_card(_state, _player, _to) do
  end

  def keep_card(_player) do
  end

  def discard_card(_player) do
  end

  def turn_to_fake(_player, _card) do
  end

  def cancel_player(_player, _target) do
  end

  def viral_spiral(_player, _targets) do
  end
end
