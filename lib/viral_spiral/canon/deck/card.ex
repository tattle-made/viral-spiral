defprotocol ViralSpiral.Canon.Deck.Card do
  def key(card)
end

defimpl ViralSpiral.Canon.Deck.Card, for: ViralSpiral.Canon.Card.Affinity do
  alias ViralSpiral.Canon.Card.Affinity

  def key(%Affinity{} = card) do
    {}
    |> Tuple.insert_at(0, card.type)
    |> Tuple.insert_at(1, card.veracity)
    |> Tuple.insert_at(2, card.target)
  end
end

defimpl ViralSpiral.Canon.Deck.Card, for: ViralSpiral.Canon.Card.Bias do
  alias ViralSpiral.Canon.Card.Bias

  def key(%Bias{} = card) do
    {}
    |> Tuple.insert_at(0, card.type)
    |> Tuple.insert_at(1, card.veracity)
    |> Tuple.insert_at(2, card.target)
  end
end

defimpl ViralSpiral.Canon.Deck.Card, for: ViralSpiral.Canon.Card.Topical do
  alias ViralSpiral.Canon.Card.Topical

  def key(%Topical{} = card) do
    {}
    |> Tuple.insert_at(0, card.type)
    |> Tuple.insert_at(1, card.veracity)
    |> Tuple.insert_at(2, nil)
  end
end

defimpl ViralSpiral.Canon.Deck.Card, for: ViralSpiral.Canon.Card.Conflated do
  alias ViralSpiral.Canon.Card.Conflated

  def key(%Conflated{} = card) do
    {}
    |> Tuple.insert_at(0, card.type)
    |> Tuple.insert_at(1, card.veracity)
    |> Tuple.insert_at(2, nil)
  end
end
