defmodule ViralSpiral.Entity.Player.Changes do
  defmodule Clout do
    defstruct offset: 0
  end

  defmodule Bias do
    alias ViralSpiral.Bias

    @type t :: %__MODULE__{
            target: Bias.target(),
            offset: integer()
          }

    defstruct target: nil, offset: 0
  end

  defmodule Affinity do
    alias ViralSpiral.Affinity

    @type t :: %__MODULE__{
            target: Affinity.target(),
            offset: integer()
          }

    defstruct target: nil, offset: 0
  end

  defmodule AddToHand do
    alias ViralSpiral.Canon.Card.Sparse
    defstruct card: nil

    @type t :: %__MODULE__{
            card: Sparse.t()
          }
  end

  defmodule RemoveFromHand do
    alias ViralSpiral.Canon.Card.Sparse
    defstruct card: nil

    @type t :: %__MODULE__{
            card: Sparse.t()
          }
  end

  defmodule AddActiveCard do
    alias ViralSpiral.Canon.Card.Sparse
    defstruct card: nil

    @type t :: %__MODULE__{
            card: Sparse.t()
          }
  end

  defmodule RemoveActiveCard do
    alias ViralSpiral.Canon.Card.Sparse
    defstruct card: nil

    @type t :: %__MODULE__{
            card: Sparse.t()
          }
  end

  defmodule MakeActiveCardFake do
    alias ViralSpiral.Canon.Card.Sparse
    defstruct card: nil

    @type t :: %__MODULE__{
            card: Sparse.t()
          }
  end

  defmodule ViewArticle do
    alias ViralSpiral.Canon.Card.Sparse
    alias ViralSpiral.Canon.Article
    defstruct [:card, :article]

    @type t :: %__MODULE__{
            card: Sparse.t(),
            article: Article.t()
          }
  end
end
