defmodule ViralSpiralWeb.MultiplayerWaitingRoom.StateAdapter do
  alias ViralSpiral.Room.State

  def make_game_room(%State{} = state) do
    %{
      room: %{
        id: state.room.id,
        name: state.room.name,
        players: state.room.unjoined_players
      }
    }
  end
end
