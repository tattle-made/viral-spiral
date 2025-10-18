defmodule ViralSpiral.Entity.Changes do
  alias ViralSpiral.Entity.Player.Changes.Clout
  alias ViralSpiral.Room.Actions.Player.DiscardCard
  alias ViralSpiral.Entity.Round.Changes.NextRound
  alias ViralSpiral.Entity.Player.Changes.AddToHand
  alias ViralSpiral.Room.Playable
  alias ViralSpiral.Entity.Turn.Change.NextTurn
  alias ViralSpiral.Entity.Player.Changes.AddActiveCard
  alias ViralSpiral.Entity.Player.Changes.RemoveActiveCard
  alias ViralSpiral.Canon.DynamicCard
  alias ViralSpiral.Canon
  alias ViralSpiral.Room.Actions.Player.PassCard
  alias ViralSpiral.Room.Actions.Player.KeepCard
  alias ViralSpiral.Room.State
  alias ViralSpiral.Canon.Card.Sparse

  def change(%State{} = state, %PassCard{} = action) do
    %{card: card, from_id: from_id, to_id: to_id} = action
    sparse_card = Sparse.new(card.id, card.veracity)
    card = Canon.get_card_from_store(sparse_card)

    current_round_player_id = State.current_round_player(state).id

    current_round_player_changes = [
      {
        state.players[current_round_player_id],
        %Clout{offset: 2},
        :clout_current_turn_player_passed_card
      }
    ]

    identity_stats = state.dynamic_card.identity_stats[sparse_card]

    card =
      case identity_stats do
        nil -> card
        _ -> DynamicCard.patch(card, identity_stats)
      end

    changes =
      current_round_player_changes ++
        Playable.pass(card, state, from_id, to_id) ++
        [
          {state.players[from_id], %RemoveActiveCard{card: sparse_card}},
          {state.players[to_id], %AddActiveCard{card: sparse_card}},
          {state.turn, %NextTurn{target: to_id}}
        ]

    changes
  end

  def change(%State{} = state, %KeepCard{} = action) do
    %{from_id: from_id, card: card} = action
    sparse_card = Sparse.new(card.id, card.veracity)
    card = Canon.get_card_from_store(sparse_card)

    changes =
      Playable.keep(card, state, from_id) ++
        [
          {state.players[from_id], %RemoveActiveCard{card: sparse_card}},
          {state.players[from_id], %AddToHand{card: sparse_card}},
          {state.round, %NextRound{}}
        ]

    changes
  end

  def change(%State{} = state, %DiscardCard{} = action) do
    %{from_id: from_id, card: card} = action
    sparse_card = Sparse.new(card.id, card.veracity)
    card = Canon.get_card_from_store(sparse_card)

    changes =
      Playable.discard(card, state, from_id) ++
        [
          {state.players[from_id], %RemoveActiveCard{card: sparse_card}},
          {state.round, %NextRound{}}
        ]

    changes
  end
end
