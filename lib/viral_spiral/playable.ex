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
  def pass(_card, _state, _from, _to) do
    IO.inspect("returning changes for Bias card")
  end

  def keep(_card, _state, _from) do
  end

  def discard(_card, _state, _from) do
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
  def pass(_card, %Root{} = state, from, _to) do
    [
      {state.players[from], [type: :clout, offset: 1]},
      {state.turn, [type: :end]}
    ]
  end

  def keep(_card, _state, _from) do
    {}
  end

  def discard(_card, _state, _from) do
  end
end

defimpl ViralSpiral.Playable, for: ViralSpiral.Canon.Card.Conflated do
  def pass(_card, _state, _from, _to) do
    # IO.inspect("returning changes for Bias card")
  end

  def keep(_card, _state, _from) do
  end

  def discard(_card, _state, _from) do
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
