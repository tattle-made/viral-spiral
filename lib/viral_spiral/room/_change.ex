# defmodule ViralSpiral.Game.Change do
#   defstruct type: nil,
#             target: nil,
#             target_id: nil

#   @type change_type :: :inc | :dec | :value
#   @type target :: :chaos_counter | :clout | :affinity | :bias

#   @type t :: %__MODULE__{
#           type: change_type(),
#           target: target(),
#           target_id: String.t()
#         }
# end
