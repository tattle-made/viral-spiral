defmodule ViralSpiral.Canon do
  @moduledoc """
  Manages game's assets.

  The static assets provided by the writers and illustrators are managed using Canon.
  """

  alias ViralSpiral.Room.RoomCreateRequest
  alias ViralSpiral.Canon.Deck

  # @card_data "card.ods"
  # @encyclopedia "encyclopedia.ods"

  @true_affinity_opts type: :affinity, veracity: true
  @false_affinity_opts type: :affinity, veracity: false
  @true_bias_opts type: :bias, veracity: true
  @false_bias_opts type: :bias, veracity: false
  @true_topical_opts type: :topical, veracity: true
  @false_topical_opts type: :topical, veracity: false
  @false_conflated_opts type: :conflated, veracity: false

  defdelegate load_cards, to: Deck

  defdelegate create_store(cards), to: Deck

  defdelegate create_sets(cards), to: Deck

  def draw_true_affinity_card(deck, tgb, target) do
    opts = @true_affinity_opts ++ [tgb: tgb, target: target]
    Deck.draw_card(deck, opts)
  end

  def draw_false_affinity_card(deck, tgb, target) do
    opts = @false_affinity_opts ++ [tgb: tgb, target: target]
    Deck.draw_card(deck, opts)
  end

  def draw_true_bias_card(deck, tgb, target) do
    opts = @true_bias_opts ++ [tgb: tgb, target: target]
    Deck.draw_card(deck, opts)
  end

  def draw_false_bias_card(deck, tgb, target) do
    opts = @false_bias_opts ++ [tgb: tgb, target: target]
    Deck.draw_card(deck, opts)
  end

  def true_topical_card(deck, tgb) do
    opts = @true_topical_opts ++ [tgb: tgb]
    Deck.draw_card(deck, opts)
  end

  def false_topical_card(deck, tgb) do
    opts = @false_topical_opts ++ [tgb: tgb]
    Deck.draw_card(deck, opts)
  end

  def false_conflated_card(deck, tgb) do
    opts = @false_conflated_opts ++ [tgb: tgb]
    Deck.draw_card(deck, opts)
  end

  def encyclopedia() do
  end
end
