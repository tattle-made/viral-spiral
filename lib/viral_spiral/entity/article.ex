defmodule ViralSpiral.Entity.Article do
  alias ViralSpiral.Entity.Change

  defstruct id: nil,
            veracity: nil,
            headline: "",
            type: nil,
            content: "",
            author: ""
end
