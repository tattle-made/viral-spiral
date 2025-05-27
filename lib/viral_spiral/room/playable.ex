defprotocol ViralSpiral.Room.Playable do
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

defimpl ViralSpiral.Room.Playable, for: ViralSpiral.Canon.Card.Bias do
  require IEx
  alias ViralSpiral.Entity.Player.Changes.Bias
  alias ViralSpiral.Entity.Player.Changes.Clout
  alias ViralSpiral.Entity.Player.Map, as: PlayerMap

  @doc """
  If a player passes a Bias Card the following changes take place:
  1. their clout increases by 1
  2. their bias against the corresponding community increases by 1
  3. every player of that community loses a clout of 1
  """
  def pass(card, state, from, to) do
    sender_change = [
      {state.players[from], %Clout{offset: 1}},
      {state.players[from], %Bias{offset: 1, target: card.target}}
    ]

    change_clout_of_card_target =
      PlayerMap.of_identity(state.players, card.target)
      |> Enum.map(&{state.players[&1], %Clout{offset: -1}})

    sender_change ++ change_clout_of_card_target
  end

  def keep(card, state, from) do
    case state.players[from].biases[card.target] do
      x when x > 0 -> [{state.players[from], %Clout{offset: -1}}]
      _ -> []
    end
  end

  def discard(card, state, from) do
    case state.players[from].biases[card.target] do
      x when x > 0 -> [{state.players[from], %Clout{offset: -1}}]
      _ -> []
    end
  end
end

defimpl ViralSpiral.Room.Playable, for: ViralSpiral.Canon.Card.Affinity do
  alias ViralSpiral.Canon.Card.Affinity, as: AffinityCard
  alias ViralSpiral.Entity.Player.Changes.{Clout, Affinity}
  alias ViralSpiral.Room.State

  # Increase the player's affinity by 1
  # Increase player's clout by 1
  def pass(%AffinityCard{} = card, %State{} = state, from, to) do
    current_round_player = State.current_round_player(state)

    affinity_offset =
      case card.polarity do
        :positive -> +1
        :negative -> -1
      end

    [
      {state.players[current_round_player.id], %Clout{offset: 1}},
      {state.players[from], %Affinity{offset: affinity_offset, target: card.target}}
    ]
  end

  def keep(_card, state, from) do
    []
  end

  # End the turn
  def discard(_card, state, _from) do
    []
  end
end

defimpl ViralSpiral.Room.Playable, for: ViralSpiral.Canon.Card.Topical do
  alias ViralSpiral.Room.State
  alias ViralSpiral.Entity.Player.Changes.Clout

  # Increase passing player's clout
  # Update the turn
  def pass(_card, %State{} = state, from_id, _to_id) do
    [
      {state.players[from_id], %Clout{offset: 1}}
    ]
  end

  def keep(_card, state, from) do
    []
  end

  # End the turn
  def discard(_card, state, _from) do
    []
  end
end

defimpl ViralSpiral.Room.Playable, for: ViralSpiral.Canon.Card.Conflated do
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

defimpl ViralSpiral.Room.Playable, for: Any do
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
