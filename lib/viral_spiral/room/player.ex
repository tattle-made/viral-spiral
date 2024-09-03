defmodule ViralSpiral.Game.Player do
  alias ViralSpiral.Bias
  alias ViralSpiral.Deck.Card
  alias ViralSpiral.Game.Player
  alias ViralSpiral.Game.EngineConfig

  defstruct id: "",
            name: "",
            identity: nil,
            hand: []

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          identity: Bias.targets(),
          hand: list(Card.t())
        }

  def new() do
    %Player{
      id: UXID.generate!(prefix: "player", size: :small)
    }
  end

  def new(%EngineConfig{} = room_config) do
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

  @spec identity(Player.t()) :: Bias.target() | nil
  def identity(%Player{} = player) do
    player.identity
  end
end
