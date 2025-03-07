defmodule ViralSpiral.Mock.UXID do
  def generate!(opts \\ []) do
    prefix = Keyword.get(opts, :prefix, "default") <> "_"
    size = Keyword.get(opts, :size, :small)

    length =
      case size do
        :small -> 10
        _ -> 10
      end

    for(_ <- 1..length, into: prefix, do: <<Enum.random(~c"0123456789abcdef")>>)
  end
end
