defmodule ViralSpiral.Canon.Card.Topical do
  defstruct id: nil,
            tgb: nil,
            type: :topical,
            veracity: nil,
            polarity: :neutral,
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
