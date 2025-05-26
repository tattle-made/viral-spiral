defmodule ViralSpiral.Entity.PowerCancelPlayer.Changes do
  defmodule InitiateCancel do
    alias ViralSpiral.Affinity
    defstruct [:from_id, :to_id, :affinity, :allowed_voters]

    @type t :: %__MODULE__{
            from_id: UXID.uxid_string(),
            to_id: UXID.uxid_string(),
            affinity: Affinity.target(),
            allowed_voters: list(UXID.uxid_string())
          }
  end

  defmodule VoteCancel do
    defstruct [:from_id, :vote]

    @type t :: %__MODULE__{
            from_id: UXID.uxid_string(),
            vote: boolean()
          }
  end

  defmodule ResetCancel do
    defstruct []
  end
end
