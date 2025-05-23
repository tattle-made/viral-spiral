defmodule ViralSpiral.Canon.Deck.CardSet do
  alias ViralSpiral.Canon.Card.Sparse
  import ViralSpiral.Room.EngineConfig.Guards
  import ViralSpiral.Canon.Card.Guards

  @type key_type ::
          {:affinity, boolean(), atom()} | {:bias, boolean(), atom()} | {:topical, boolean()}
  @type member :: %{id: String.t(), tgb: integer()}
  @type card_sets :: %{optional(key_type()) => member()}

  @doc """
  Creates a key for the card set in Deck, when you don't have a card.

  General Syntax {type, target, veracity} or {type, veracity}
  """
  def key(:affinity, veracity, target)
      when is_affinity(target) and is_boolean(veracity) do
    {:affinity, veracity, target}
  end

  def key(:bias, veracity, target) when is_community(target) and is_boolean(veracity) do
    {:bias, veracity, target}
  end

  def key(:topical, veracity, nil) when is_boolean(veracity) do
    {:topical, veracity, nil}
  end

  def key(:conflated, veracity, nil) when is_boolean(veracity) do
    {:conflated, veracity, nil}
  end

  def make_member(card) when is_card(card) do
    %{id: card.id, tgb: card.tgb}
  end

  @spec make_member(String.t(), integer()) :: %{id: String.t(), tgb: integer()}
  def make_member(card_id, card_tgb) do
    %{id: card_id, tgb: card_tgb}
  end

  # @spec make_member(member()) ::
  #         def(make_member(%Sparse{} = card)) do
  #   %{id: card.id, tgb: card.tgb}
  # end
end
