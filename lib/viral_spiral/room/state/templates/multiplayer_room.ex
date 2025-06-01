defmodule ViralSpiral.Room.State.Templates.MultiplayerRoom do
  alias ViralSpiral.Room.State

  def make(room_name) do
    State.skeleton(room_name: room_name)
  end
end
