defmodule CardFixtures do
  alias ViralSpiral.Canon.Card.Affinity

  @doc """
  attrs is a map with keys suitable for`ViralSpiral.Canon.Card.Affinity`
  """
  def affinity_card_true_anti_cat(attrs \\ %{}) do
    struct(
      %Affinity{id: "card_XHSIODS", target: :cat, veracity: true, polarity: :negative},
      attrs
    )
  end

  def affinity_card_true_pro_cat(attrs \\ %{}) do
    struct(%Affinity{target: :cat, veracity: true, polarity: :positive}, attrs)
  end
end
