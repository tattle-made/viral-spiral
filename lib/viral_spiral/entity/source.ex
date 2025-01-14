defmodule ViralSpiral.Entity.Source do
  defstruct [:owner, :headline, :content, :author, :type]

  @type t :: %__MODULE__{
          owner: String.t(),
          headline: String.t(),
          content: String.t(),
          author: String.t(),
          type: String.t()
        }
end
