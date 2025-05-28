defmodule ViralSpiral.Room.StateTransformation do
  @moduledoc """
  A helper to directly modify `State`

  This module is to be used only for manual debugging and in tests. It helps modify the game state to any desired state.
  """
  alias ViralSpiral.Canon.Card.Sparse
  alias ViralSpiral.Canon
  alias ViralSpiral.Canon.Deck.CardSet
  alias ViralSpiral.Room.State

  def set_chaos(%State{} = root, chaos) do
    room = root.room
    new_room = %{room | chaos: chaos}
    Map.put(root, :room, new_room)
  end

  def player_by_names(%State{} = state) do
    players = state.players

    Map.keys(state.players)
    |> Enum.reduce(%{}, fn player_id, all ->
      Map.put(all, String.to_atom(players[player_id].name), players[player_id])
    end)
  end

  def player_id_by_names(%State{} = state) do
    players = state.players

    Map.keys(state.players)
    |> Enum.reduce(%{}, fn player_id, all ->
      Map.put(all, String.to_atom(players[player_id].name), player_id)
    end)
  end

  def active_cards(%State{} = state, player_id) do
    state.players[player_id].active_cards
  end

  @spec active_card(State.t(), String.t(), integer()) :: tuple() | nil
  def active_card(%State{} = state, player_id, ix) do
    case state.players[player_id].active_cards |> Enum.at(ix) do
      nil -> nil
      sparse_card -> sparse_card
    end
  end

  def update_round(%State{} = state, attrs) do
    state = put_in(state.round.order, attrs[:order] || state.round.order)
    state = put_in(state.round.current, attrs[:current] || state.round.current)
    state
  end

  def update_turn(%State{} = state, attrs) do
    state = put_in(state.turn.current, attrs[:current] || state.turn.current)
    state = put_in(state.turn.pass_to, attrs[:pass_to] || state.round.pass_to)
    state = put_in(state.turn.path, attrs[:path] || state.turn.path)
    state
  end

  def update_player(%State{} = state, player_id, attrs) do
    player = state.players[player_id]
    player = put_in(player.identity, attrs[:identity] || player.identity)
    player = put_in(player.active_cards, attrs[:active_cards] || player.active_cards)
    player = put_in(player.clout, attrs[:clout] || player.clout)
    player = put_in(player.affinities, attrs[:affinities] || player.affinities)
    player = put_in(player.biases, attrs[:biases] || player.biases)
    state = put_in(state.players[player_id], player)
    state
  end

  def update_room(%State{} = state, attrs) do
    chaos = Map.get(attrs, :chaos, 0)
    state = put_in(state.room.chaos, chaos)
    state
  end

  def draw_card(%State{} = state, {type, veracity, target}) do
    card_sets = state.deck.available_cards
    set_key = CardSet.key(type, veracity, target)
    cardset_member = Canon.draw_card_from_deck(card_sets, set_key, 4)
    Sparse.new(cardset_member.id, true)
  end
end
