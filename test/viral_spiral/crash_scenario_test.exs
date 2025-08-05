defmodule ViralSpiral.CrashScenarioTest do
  alias ViralSpiral.Entity.Deck.Changes.RemoveCard
  alias ViralSpiral.Room.CardDraw
  alias ViralSpiral.Room.State
  alias ViralSpiral.Canon
  use ExUnit.Case

  test "crash upon keeping/discarding/passing" do
    :rand.seed(:exsss, {123, 899, 254})
    {state, players} = StateFixtures.new_game_with_four_players()
    %{adhiraj: adhiraj, aman: aman, farah: farah, krys: krys} = players

    %{deck: deck} = state
    card_sets = deck.available_cards
    card_store = Canon.get_card_store()
    current_player = State.current_round_player(state)
    draw_constraints = State.draw_constraints(state)
    card_type = CardDraw.draw_type(draw_constraints)
    chaos = draw_constraints.chaos

    card = Canon.draw_card_from_deck(state.deck.available_cards, card_type, chaos)
    remove_card_changes = [{state.deck, %RemoveCard{card_type: card_type, card: card}}]
    state = State.apply_changes(state, remove_card_changes)
    IO.inspect(state.deck.available_cards[card_type] |> MapSet.size())

    card = Canon.draw_card_from_deck(state.deck.available_cards, card_type, chaos)
    remove_card_changes = [{state.deck, %RemoveCard{card_type: card_type, card: card}}]
    state = State.apply_changes(state, remove_card_changes)
    IO.inspect(state.deck.available_cards[card_type] |> MapSet.size())

    card = Canon.draw_card_from_deck(state.deck.available_cards, card_type, chaos)
    remove_card_changes = [{state.deck, %RemoveCard{card_type: card_type, card: card}}]
    state = State.apply_changes(state, remove_card_changes)
    IO.inspect(state.deck.available_cards[card_type] |> MapSet.size())

    card = Canon.draw_card_from_deck(state.deck.available_cards, card_type, chaos)
    remove_card_changes = [{state.deck, %RemoveCard{card_type: card_type, card: card}}]
    state = State.apply_changes(state, remove_card_changes)
    IO.inspect(state.deck.available_cards[card_type] |> MapSet.size())

    card = Canon.draw_card_from_deck(state.deck.available_cards, card_type, chaos)
    remove_card_changes = [{state.deck, %RemoveCard{card_type: card_type, card: card}}]
    state = State.apply_changes(state, remove_card_changes)
    IO.inspect(state.deck.available_cards[card_type] |> MapSet.size())

    card = Canon.draw_card_from_deck(state.deck.available_cards, card_type, chaos)
    remove_card_changes = [{state.deck, %RemoveCard{card_type: card_type, card: card}}]
    state = State.apply_changes(state, remove_card_changes)
    IO.inspect(state.deck.available_cards[card_type] |> MapSet.size())

    card = Canon.draw_card_from_deck(state.deck.available_cards, card_type, chaos)
    remove_card_changes = [{state.deck, %RemoveCard{card_type: card_type, card: card}}]
    state = State.apply_changes(state, remove_card_changes)
    IO.inspect(state.deck.available_cards[card_type] |> MapSet.size())

    card = Canon.draw_card_from_deck(state.deck.available_cards, card_type, chaos)
    remove_card_changes = [{state.deck, %RemoveCard{card_type: card_type, card: card}}]
    state = State.apply_changes(state, remove_card_changes)
    IO.inspect(state.deck.available_cards[card_type] |> MapSet.size())

    assert 1 == 1
  end
end
