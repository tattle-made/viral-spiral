defmodule ViralSpiral.Game.Player do
  defstruct id: "",
            name: "",
            biases: [],
            affinities: [],
            score: 0,
            hand: nil

  def new() do
    %__MODULE__{
      id: UXID.generate!(prefix: "player", size: :small)
    }
  end

  def set_name(%__MODULE__{} = player, name) do
    %{player | name: name}
  end
end
