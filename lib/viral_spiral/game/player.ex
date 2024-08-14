defmodule ViralSpiral.Game.Player do
  alias ViralSpiral.Game.Player
  alias ViralSpiral.Game.RoomConfig

  defstruct id: "",
            name: "",
            identity: nil,
            hand: []

  def new() do
    %Player{
      id: UXID.generate!(prefix: "player", size: :small)
    }
  end

  def new(%RoomConfig{} = room_config) do
    %Player{
      id: UXID.generate!(prefix: "player", size: :small),
      identity: Enum.shuffle(room_config.communities) |> Enum.at(0)
    }
  end

  def set_name(%Player{} = player, name) do
    %{player | name: name}
  end

  def set_identity(%Player{} = player, identity) do
    %{player | identity: identity}
  end
end
