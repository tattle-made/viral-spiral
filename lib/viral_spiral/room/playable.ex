defprotocol ViralSpiral.Playable do
  @moduledoc """
  Returns Changes to be made when a card action takes place.

  A protocol for cards to implement.
  """

  @fallback_to_any true
  def pass(card, state, from, to)

  @fallback_to_any true
  def keep(card, state, from)

  @fallback_to_any true
  def discard(card, state, from)
end

defimpl ViralSpiral.Playable, for: ViralSpiral.Canon.Card.Bias do
  require IEx

  @doc """
  If a player passes a Bias Card the following changes take place:
  1. their clout increases by 1
  2. their bias against the corresponding community increases by 1
  3. every player of that community loses a clout of 1
  """
  def pass(card, state, from, to) do
    [
      {state.turn, [type: :next, target: to]},
      {state.players[from], [type: :clout, offset: 1]},
      {state.players[from], [type: :bias, target: card.target, offset: 1]}
    ] ++
      (Map.keys(state.players)
       |> Enum.filter(&(state.players[&1].identity == card.target))
       |> Enum.map(&{state.players[&1], [type: :clout, offset: -1]}))
  end

  def keep(card, state, from) do
    [
      {state.round, [type: :next]},
      {state.turn, [type: :new, round: state.round]},
      {state.players[from], [type: :add_to_hand, card_id: card.id]}
    ]
  end

  # @spec discard(%ViralSpiral.Canon.Card.Bias{}, any(), any()) :: nil
  def discard(_card, state, _from) do
    [
      {state.round, [type: :next]},
      {state.turn, [type: :new, round: state.round]}
    ]
  end
end

defimpl ViralSpiral.Playable, for: ViralSpiral.Canon.Card.Affinity do
  # Increase the player's affinity by 1
  # Increase player's clout by 1
  def pass(card, state, from, to) do
    affinity_offset =
      case card.polarity do
        :positive -> +1
        :negative -> -1
      end

    [
      {state.players[from], [type: :affinity, offset: affinity_offset, target: card.target]},
      {state.players[from], [type: :clout, offset: 1]},
      {state.turn, [type: :next, target: to]}
    ]
  end

  # End the turn
  def keep(_card, state, from) do
    [
      {state.round, [type: :next]},
      {state.turn, [type: :new, round: state.round]},
      {state.players[from], [type: :add_to_hand]}
    ]
  end

  # End the turn
  def discard(_card, state, _from) do
    [
      {state.turn, [type: :end]},
      {state.turn, [type: :new, round: state.round]}
    ]
  end
end

defimpl ViralSpiral.Playable, for: ViralSpiral.Canon.Card.Topical do
  alias ViralSpiral.Room.State.Root

  # Increase passing player's clout
  # Update the turn
  def pass(_card, %Root{} = state, from, to) do
    [
      {state.players[from], [type: :clout, offset: 1]},
      {state.turn, [type: :next, target: to]}
    ]
  end

  def keep(_card, state, from) do
    [
      {state.round, [type: :next]},
      {state.turn, [type: :new, round: state.round]},
      {state.players[from], [type: :add_to_hand]}
    ]
  end

  # End the turn
  def discard(_card, state, _from) do
    [
      {state.turn, [type: :end]},
      {state.turn, [type: :new, round: state.round]}
    ]
  end
end

defimpl ViralSpiral.Playable, for: ViralSpiral.Canon.Card.Conflated do
  def pass(_card, state, _from, _to) do
    state
  end

  def keep(_card, state, _from) do
    state
  end

  def discard(_card, state, _from) do
    state
  end
end

defimpl ViralSpiral.Playable, for: Any do
  def pass(_card, state, _from, _to) do
    state
  end

  def keep(_card, state, _from) do
    state
  end

  def discard(_card, state, _from) do
    state
  end
end
