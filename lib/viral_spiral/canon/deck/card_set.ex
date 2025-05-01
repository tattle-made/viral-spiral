defmodule ViralSpiral.Canon.Deck.CardSet do
  import ViralSpiral.Room.EngineConfig.Guards
  import ViralSpiral.Canon.Card.Guards

  @type key_type ::
          {:affinity, atom(), boolean()} | {:bias, atom(), boolean()} | {:topical, boolean()}
  @type member :: %{id: String.t(), tgb: integer()}

  @doc """
  Creates a key for the card set in Deck, when you don't have a card.

  General Syntax {type, target, veracity} or {type, veracity}
  """
  def key(:affinity, target, veracity)
      when is_affinity(target) and is_boolean(veracity) do
    {:affinity, veracity, target}
  end

  def key(:bias, target, veracity) when is_community(target) and is_boolean(veracity) do
    {:bias, veracity, target}
  end

  def key(:topical, veracity) when is_boolean(veracity) do
    {:topical, veracity}
  end

  def key(:conflated, veracity) when is_boolean(veracity) do
    {:conflated, veracity}
  end

  def make_member(card) when is_card(card) do
    %{id: card.id, tgb: card.tgb}
  end
end
