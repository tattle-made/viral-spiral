defmodule ViralSpiral.Canon.Card do
  alias ViralSpiral.Canon.Card.Bias
  alias ViralSpiral.Affinity

  @type t :: Affinity.t() | Bias.t()
end
