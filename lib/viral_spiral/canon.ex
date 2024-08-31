defmodule ViralSpiral.Canon do
  @moduledoc """
  Manages game's assets.

  The static assets provided by the writers and illustrators are managed using Canon.
  """

  alias ViralSpiral.Room.RoomCreateRequest
  alias ViralSpiral.Canon.Deck

  # @card_data "card.ods"
  # @encyclopedia "encyclopedia.ods"

  defdelegate load_cards, to: Deck

  defdelegate create_store(cards), to: Deck

  defdelegate create_sets(cards, opts), to: Deck

  def encyclopedia() do
  end
end
