defmodule ViralSpiral.Room.Analytics do
  alias ViralSpiral.Room.State

  @doc """
  identity of the player with most clout
  """
  def dominant_community(%State{} = state) do
  end
end

defmodule ViralSpiral.Room.Analytics.GameState do
  alias ViralSpiral.Room.State

  def analytics(%State{} = _state) do
    %{
      unpopular_affinity: :skub,
      popular_affinity: :houseboat,
      dominant_community: :red,
      other_community: :blue,
      oppressed_community: :yellow
    }
  end
end
