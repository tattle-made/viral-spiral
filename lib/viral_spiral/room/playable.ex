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
  alias ViralSpiral.Entity.ChangeMessages.MessageCode
  alias ViralSpiral.Entity.Room.Changes.OffsetChaos
  alias ViralSpiral.Entity.Player.Changes.Bias
  alias ViralSpiral.Entity.Player.Changes.Clout
  alias ViralSpiral.Entity.Player.Map, as: PlayerMap
  alias ViralSpiral.Room.State

  @doc """
  If a player passes a Bias Card the following changes take place:
  1. their clout increases by 1
  2. their bias against the corresponding community increases by 1
  3. every player of that community loses a clout of 1
  """
  def pass(card, state, from_id, _to) do
    sender_changes = [
      {
        state.players[from_id],
        %Bias{offset: 1, target: card.target},
        :bias_current_turn_player_shared_bias_card
      }
    ]

    change_clout_of_card_target =
      PlayerMap.of_identity(state.players, card.target)
      |> Enum.map(
        &{
          state.players[&1],
          %Clout{offset: -1},
          :clout_current_turn_player_shared_bias_card_targetting_other_player
        }
      )

    change_room_chaos = [
      {
        state.room,
        %OffsetChaos{offset: 1},
        :chaos_current_turn_player_shared_bias_card
      }
    ]

    sender_changes ++ change_clout_of_card_target ++ change_room_chaos
  end

  def keep(card, state, from) do
    case state.players[from].biases[card.target] do
      nil ->
        []

      x when x > 0 ->
        [
          {
            state.players[from],
            %Clout{offset: -1},
            :clout_current_turn_player_kept_card_with_shared_bias
          }
        ]

      _ ->
        []
    end
  end

  def discard(card, state, from) do
    case state.players[from].biases[card.target] do
      nil ->
        []

      x when x > 0 ->
        [
          {
            state.players[from],
            %Clout{offset: -1},
            :clout_current_turn_player_discarded_card_with_shared_bias
          }
        ]

      _ ->
        []
    end
  end
end

defimpl ViralSpiral.Room.Playable, for: ViralSpiral.Canon.Card.Affinity do
  alias ViralSpiral.Entity.ChangeMessages.MessageCode
  alias ViralSpiral.Entity.ChangeMessages
  alias ViralSpiral.Entity.Player.Changes.Bias
  alias ViralSpiral.Canon.Card.Affinity, as: AffinityCard
  alias ViralSpiral.Entity.Player.Changes.{Clout, Affinity}
  alias ViralSpiral.Room.State
  alias ViralSpiral.Entity.Player.Map, as: PlayerMap
  alias ViralSpiral.Entity.Room.Changes.OffsetChaos

  # Increase the player's affinity by 1
  # Increase player's clout by 1
  def pass(%AffinityCard{} = card, %State{} = state, from_id, _to) do
    affinity_offset =
      case card.polarity do
        :positive -> +1
        :negative -> -1
      end

    conflation_changes =
      case Map.get(card, :bias, nil) do
        nil ->
          []

        _ ->
          [
            {
              state.players[from_id],
              %Bias{offset: 1, target: card.bias.target},
              :bias_current_turn_player_shared_bias_card
            }
          ]
      end

    change_clout_of_card_target =
      case Map.get(card, :bias, nil) do
        nil ->
          []

        _ ->
          PlayerMap.of_identity(state.players, card.bias.target)
          |> Enum.map(
            &{
              state.players[&1],
              %Clout{offset: -1},
              :clout_current_turn_player_shared_bias_card_targetting_other_player
            }
          )
      end

    sender_changes = [
      {
        state.players[from_id],
        %Affinity{offset: affinity_offset, target: card.target},
        :affinity_current_turn_player_shared_affinity_card
      }
    ]

    # To check in case of turn to fake power is used and the card has bias towards any communtiy.
    bias = Map.get(card, :bias)

    change_room_chaos =
      if bias do
        [{state.room, %OffsetChaos{offset: 1}, :chaos_current_turn_player_shared_bias_card}]
      else
        []
      end

    sender_changes ++ conflation_changes ++ change_clout_of_card_target ++ change_room_chaos
  end

  def keep(card, state, from) do
    card_holder = state.players[from]
    players_left_to_pass = length(state.turn.pass_to)

    keep_affinity_card_changes =
      case card.polarity do
        :positive ->
          case card_holder.affinities[card.target] do
            x when x > 0 and players_left_to_pass > 0 ->
              [
                {
                  card_holder,
                  %Clout{offset: -1},
                  :clout_current_turn_player_kept_card_with_shared_affinity
                }
              ]

            _ ->
              []
          end

        :negative ->
          case card_holder.affinities[card.target] do
            x when x < 0 and players_left_to_pass > 0 ->
              [
                {
                  card_holder,
                  %Clout{offset: -1},
                  :clout_current_turn_player_kept_card_with_shared_affinity
                }
              ]

            _ ->
              []
          end
      end

    keep_affinity_card_changes
  end

  # End the turn
  def discard(card, state, from) do
    card_holder = state.players[from]
    players_left_to_pass = length(state.turn.pass_to)

    discard_affinity_card_changes =
      case card.polarity do
        :positive ->
          case card_holder.affinities[card.target] do
            x when x > 0 and players_left_to_pass > 0 ->
              [
                {
                  card_holder,
                  %Clout{offset: -1},
                  :clout_current_turn_player_discarded_card_with_shared_affinity
                }
              ]

            _ ->
              []
          end

        :negative ->
          case card_holder.affinities[card.target] do
            x when x < 0 and players_left_to_pass > 0 ->
              [
                {
                  card_holder,
                  %Clout{offset: -1},
                  :clout_current_turn_player_discarded_card_with_shared_affinity
                }
              ]

            _ ->
              []
          end
      end

    discard_affinity_card_changes
  end
end

defimpl ViralSpiral.Room.Playable, for: ViralSpiral.Canon.Card.Topical do
  alias ViralSpiral.Entity.ChangeMessages.MessageCode
  alias ViralSpiral.Entity.Player.Changes.Bias
  alias ViralSpiral.Room.State
  alias ViralSpiral.Entity.Player.Changes.Clout
  alias ViralSpiral.Entity.Player.Map, as: PlayerMap
  alias ViralSpiral.Entity.Room.Changes.OffsetChaos

  def pass(card, %State{} = state, from_id, _to_id) do
    conflation_changes =
      case card.bias do
        nil ->
          []

        _ ->
          [
            {
              state.players[from_id],
              %Bias{offset: 1, target: card.bias.target},
              :bias_current_turn_player_shared_bias_card
            }
          ]
      end

    change_clout_of_card_target =
      case card.bias do
        nil ->
          []

        _ ->
          PlayerMap.of_identity(state.players, card.bias.target)
          |> Enum.map(
            &{
              state.players[&1],
              %Clout{offset: -1},
              :clout_current_turn_player_shared_bias_card_targetting_other_player
            }
          )
      end

    # To check in case of turn to fake power is used and the card has bias towards any communtiy.
    bias = Map.get(card, :bias)

    change_room_chaos =
      if bias do
        [{state.room, %OffsetChaos{offset: 1}, :chaos_current_turn_player_shared_bias_card}]
      else
        []
      end

    conflation_changes ++ change_clout_of_card_target ++ change_room_chaos
  end

  def keep(_card, _state, _from) do
    []
  end

  # End the turn
  def discard(_card, _state, _from) do
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
