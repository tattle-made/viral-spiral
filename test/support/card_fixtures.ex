defmodule CardFixtures do
  alias ViralSpiral.Canon.Card.Affinity

  @doc """
  attrs is a map with keys suitable for`Affinity`
  """
  def affinity_card_true_cat(attrs) do
    struct(%Affinity{target: :cat, veracity: true}, attrs)
  end
end
