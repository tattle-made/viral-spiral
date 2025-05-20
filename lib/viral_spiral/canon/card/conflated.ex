defmodule ViralSpiral.Canon.Card.Conflated do
  defstruct id: nil,
            tgb: nil,
            type: :conflated,
            veracity: false,
            polarity: :neutral,
            headline: nil,
            image: nil,
            article_id: nil

  @type t :: %__MODULE__{
          id: String.t(),
          tgb: integer()
        }
end
