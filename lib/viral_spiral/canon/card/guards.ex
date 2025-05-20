defmodule ViralSpiral.Canon.Card.Guards do
  alias ViralSpiral.Canon.Card.Conflated
  alias ViralSpiral.Canon.Card.Bias
  alias ViralSpiral.Canon.Card.Affinity
  alias ViralSpiral.Canon.Card.Topical

  defguard is_card(card)
           when is_struct(card, Topical) or
                  is_struct(card, Affinity) or
                  is_struct(card, Bias) or
                  is_struct(card, Conflated)
end
