defmodule ViralSpiral.Deck.CardGuards do
  @card_types Application.compile_env(:viral_spiral, CardConfig)[:card_types]

  defguard is_card_type(value) when value in @card_types
end
