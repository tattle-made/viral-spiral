defmodule ViralSpiral.Canon.Card.Bias do
  defstruct id: nil,
            tgb: nil,
            type: :bias,
            target: nil,
            veracity: nil,
            polarity: :neutral,
            headline: nil,
            image: nil,
            article_id: nil

  @type t :: %__MODULE__{
          id: String.t(),
          tgb: integer()
        }
end
