defmodule ViralSpiral.Canon.Card.Conflated do
  defstruct id: nil,
            tgb: nil,
            type: :conflated,
            veracity: false,
            headline: nil,
            image: nil,
            article_id: nil,
            affinity: nil,
            bias: nil

  @type t :: %__MODULE__{
          id: String.t(),
          tgb: integer()
        }
end
