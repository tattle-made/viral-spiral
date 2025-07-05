defmodule ViralSpiral.Entity do
  @moduledoc """
  Context for Entity
  """
  alias ViralSpiral.Entity.Room.Changes.EndGame

  def make_game_end_change({:no_over}) do
    %EndGame{}
  end

  def make_game_end_change({:over, :world}) do
    %EndGame{reason: :world}
  end

  def make_game_end_change({:over, :player, player_id}) when is_bitstring(player_id) do
    %EndGame{reason: :player, winner_id: player_id}
  end
end
