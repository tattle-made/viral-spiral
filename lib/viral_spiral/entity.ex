defmodule ViralSpiral.Entity do
  @moduledoc """
  Context for Entity
  """
  alias ViralSpiral.Entity.Room.Changes.EndGame

  def make_game_end_change({:no_over}), do: %EndGame{}

  def make_game_end_change({:over, :world}), do: %EndGame{reason: :world}

  def make_game_end_change({:over, :player}), do: %EndGame{reason: :player}
end
