defmodule ViralSpiral.Entity.Turn.Exception do
  defmodule IllegalPass do
    defexception message: "You can't pass to this player in this turn"
  end
end
