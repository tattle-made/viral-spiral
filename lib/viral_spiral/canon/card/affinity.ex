defmodule ViralSpiral.Canon.Card.Affinity do
  defstruct id: nil,
            tgb: nil,
            type: :affinity,
            target: nil,
            veracity: nil,
            polarity: nil,
            headline: nil,
            fake_headline: nil,
            image: nil,
            article_id: nil,
            bias: nil

  @type t :: %__MODULE__{
          id: String.t(),
          tgb: integer()
        }
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
