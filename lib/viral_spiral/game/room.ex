defmodule ViralSpiral.Game.Room do
  defstruct id: "",
            name: "",
            state: :uninitialized

  def new() do
    %__MODULE__{
      id: UXID.generate!(prefix: "room", size: :small)
    }
    |> set_state(:initialized)
  end

  def set_state(%__MODULE__{} = game, :initialized), do: %__MODULE__{game | state: :initialized}
  def set_state(%__MODULE__{} = game, :running), do: %__MODULE__{game | state: :running}
  def set_state(%__MODULE__{} = game, :paused), do: %__MODULE__{game | state: :paused}
  def set_state(%__MODULE__{} = game, :blocked), do: %__MODULE__{game | state: :blocked}
  def set_state(%__MODULE__{} = game, _), do: game
end
