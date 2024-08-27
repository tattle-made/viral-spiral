defmodule ViralSpiral.Canon.Card.Affinity do
  defstruct id: nil,
            tgb: nil,
            type: :affinity,
            target: nil,
            veracity: nil,
            polarity: nil,
            headline: nil,
            image: nil
end

# defmodule ViralSpiral.Canon.Card.Affinity.Cat do
#   alias ViralSpiral.Canon.Card.Affinity

#   def new(tgb, target, veracity, polarity, headline, image) do
#     %Affinity{
#       tgb: tgb,
#       target: target,
#       veracity: veracity,
#       polarity: polarity,
#       headline: headline,
#       image: image
#     }
#   end
# end
