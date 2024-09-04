defprotocol ViralSpiral.CardShare do
  @moduledoc """
  Returns Changes to be made when a card action takes place.
  """

  @fallback_to_any true
  def pass(card, state, from, to)

  @fallback_to_any true
  def keep(card, state, from)

  @fallback_to_any true
  def discard(card, state, from)
end

defimpl ViralSpiral.CardShare, for: ViralSpiral.Canon.Card.Topical do
  def pass(_card, _state, _from, _to) do
    # IO.inspect("returning changes for Bias card")
  end

  def keep(_card, _state, _from) do
  end

  def discard(_card, _state, _from) do
  end
end

defimpl ViralSpiral.CardShare, for: ViralSpiral.Canon.Card.Affinity do
  # Increase the player's affinity by 1
  # Increase player's clout by 1
  def pass(card, state, from, to) do
    [
      {state.player_map[from], [type: :affinity, offset: -1, target: card.target]},
      {state.player_map[from], [type: :clout, offset: 1]},
      {state.turn, [type: :next, target: to]}
    ]
  end

  # End the turn
  def keep(_card, state, _from) do
    [
      {state.turn, [type: :end]}
    ]
  end

  # End the turn
  def discard(_card, state, _from) do
    [
      {state.turn, [type: :end]}
    ]
  end
end

defimpl ViralSpiral.CardShare, for: ViralSpiral.Canon.Card.Topical do
  alias ViralSpiral.Game.State

  # Increase passing player's clout
  # Update the turn
  def pass(_card, %State{} = state, from, _to) do
    [
      {state.player_map[from], [type: :clout, offset: 1]},
      {state.turn, [type: :end]}
    ]
  end

  def keep(_card, _state, _from) do
    {}
  end

  def discard(_card, _state, _from) do
  end
end

defimpl ViralSpiral.CardShare, for: ViralSpiral.Canon.Card.Conflated do
  def pass(_card, _state, _from, _to) do
    # IO.inspect("returning changes for Bias card")
  end

  def keep(_card, _state, _from) do
  end

  def discard(_card, _state, _from) do
  end
end

defimpl ViralSpiral.CardShare, for: Any do
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
