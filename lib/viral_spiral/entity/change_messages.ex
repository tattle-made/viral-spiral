defmodule ViralSpiral.Entity.ChangeMessages do
  @moduledoc """
  Human readable messages that explain changes in state.

  After every `ViralSpiral.Room.Actions`, many variables within `ViralSpiral.Room.State` change. `ChangeMessages` help explain the change to the players in a simple manner.

  Every entity change is defined via a tuple which can take the form {target, change} or {target, change, reason}. This module defines helpers to deal with the reason component of this tuple. For instance a possible change to increase the clout of the current round player would be
  ```elixir
  {
    state.players[current_round_player_id],
    %Clout{offset: 1},
    ChangeMessages.message_code("TURN_OWNER")
  }
  ```
  Use `message_code` function to get atom keys defined in `@message_codes` in their code,
  The actual text shown to the user is defined in `@nessages`

  # Example Usage
  ```elixir
  changes = [
    {
      state.players[current_round_player_id],
      %Clout{offset: 1},
      :clout_current_turn_player_passed_card
    },
    {
      state.players[current_round_player_id],
      %Clout{offset: 1},
      :clout_current_turn_player_passed_card
    }
  ]

  change_reasons = ChangeMessages.message_reasons(changes)
  user_friendly_message = ChangeMessages.message_string(changes)
  ```
  """

  # Code names for various messages.
  # General convention of naming messages is the name of the entity target being changed followed by the reason for the change.
  @reason_codes [
    :clout_current_turn_player_passed_card,
    :clout_current_turn_player_kept_card_with_shared_affinity,
    :clout_current_turn_player_discarded_card_with_shared_affinity,
    :clout_current_turn_player_kept_card_with_shared_bias,
    :clout_current_turn_player_discarded_card_with_shared_bias,
    :clout_current_turn_player_shared_card_with_bias,
    :clout_current_turn_player_shared_bias_card_targetting_other_player,
    :affinity_current_turn_player_shared_affinity_card,
    :bias_current_turn_player_shared_bias_card,
    :chaos_current_turn_player_shared_bias_card
  ]

  @reason_texts %{
    clout_current_turn_player_passed_card:
      "<%= entity.name %>'s clout has increased because a player passed the card they drew.",
    clout_current_turn_player_kept_card_with_shared_affinity:
      "<%= entity.name %> lost a clout because they kept the card which shares their affinity",
    clout_current_turn_player_discarded_card_with_shared_affinity:
      "<%= entity.name %> lost a clout point because they discarded the card which shares their affinity",
    clout_current_turn_player_kept_card_with_shared_bias:
      "<%= entity.name %> lost a clout because they kept the card which shares their bias",
    clout_current_turn_player_discarded_card_with_shared_bias:
      "<%= entity.name %> lost a clout because they discarded the card which shares their bias",
    clout_current_turn_player_shared_card_with_bias:
      "<%= entity.name %> earned a bias against <%= change.target %> because they shared a bias card",
    clout_current_turn_player_shared_bias_card_targetting_other_player:
      "<%= entity.name %> lost a clout because a bias card targetting their identity was shared",
    affinity_current_turn_player_shared_affinity_card:
      "<%= entity.name %> earned a <% change.target %> affinity because they shared an affinity card",
    bias_current_turn_player_shared_bias_card:
      "<%= entity.name %> earned a <%= change.target %> bias because they shared a bias card",
    chaos_current_turn_player_shared_bias_card:
      "chaos decreased by 1 because a bias card was shared"
  }

  def reason_text(reason_code, target, change) when reason_code in @reason_codes do
    EEx.eval_string(@reason_texts[reason_code], entity: target, change: change)
  end

  @doc """
  Get list of reasons.
  """
  def message_reasons(changes) when is_list(changes) do
    Enum.reduce(changes, [], fn msg, reasons ->
      case msg do
        {_target, _change, reason} ->
          reasons ++ [reason]

        {_target, _change} ->
          reasons
      end
    end)
  end

  @doc """
  Get full message string with substitution.
  """
  def message_string(changes) when is_list(changes) do
    Enum.reduce(changes, [], fn msg, full_msg ->
      case msg do
        {target, change, reason} ->
          full_msg ++ [reason_text(reason, target, change)]

        {_target, _change} ->
          full_msg
      end
    end)
    |> Enum.filter(fn msg -> msg != "" end)
  end
end
