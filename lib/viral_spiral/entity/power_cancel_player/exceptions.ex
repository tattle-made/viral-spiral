defmodule ViralSpiral.Entity.PowerCancelPlayer.Exceptions do
  defmodule VoteAlreadyRegistered do
    defexception message: "This player has already voted and can't vote again."
  end
end
