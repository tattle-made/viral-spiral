defmodule ViralSpiral.Room.Notification do
  @moduledoc """
  Handles all game action notifications and generates notification text based on game state and actions.
  """

  @doc """
  Main function to generate notification text for any game action.
  Returns the notification text string or nil if no notification should be shown.
  """
  def generate_notification(state, action_type, params) do
    case action_type do
      "pass_to" ->
        generate_pass_notification(state, params)

      "keep" ->
        generate_keep_notification(state, params)

      "discard" ->
        generate_discard_notification(state, params)

      "initiate_cancel" ->
        generate_initiate_cancel_notification(state, params)

      "cancel_vote" ->
        generate_cancel_vote_notification(state, params)

      "initiate_viral_spiral" ->
        generate_viral_spiral_notification(state, params)

      _ ->
        nil
    end
  end

  # Private functions for each action type
  defp generate_pass_notification(state, params) do
    with from_id when not is_nil(from_id) <- params["from_id"],
         to_id when not is_nil(to_id) <- params["to_id"] do
      from_name = get_player_name_by_id(state.players, from_id)
      to_name = get_player_name_by_id(state.players, to_id)
      "#{from_name} passed a card to #{to_name}"
    else
      _ -> nil
    end
  end

  defp generate_keep_notification(state, params) do
    with from_id when not is_nil(from_id) <- params["from_id"] do
      player_name = get_player_name_by_id(state.players, from_id)
      "#{player_name} kept a card"
    else
      _ -> nil
    end
  end

  defp generate_discard_notification(state, params) do
    with from_id when not is_nil(from_id) <- params["from_id"] do
      player_name = get_player_name_by_id(state.players, from_id)
      "#{player_name} discarded a card"
    else
      _ -> nil
    end
  end

  defp generate_initiate_cancel_notification(state, params) do
    with from_id when not is_nil(from_id) <- params["from_id"],
         target_id when not is_nil(target_id) <- params["target_id"] do
      player_name = get_player_name_by_id(state.players, from_id)
      target_name = get_player_name_by_id(state.players, target_id)
      "#{player_name} initiated cancel on #{target_name}"
    else
      _ -> nil
    end
  end

  defp generate_cancel_vote_notification(state, params) do
    with from_id when not is_nil(from_id) <- params["from_id"],
         vote when not is_nil(vote) <- params["vote"] do
      player_name = get_player_name_by_id(state.players, from_id)
      vote_text = if vote, do: "voted YES", else: "voted NO"
      "#{player_name} #{vote_text} to cancel"
    else
      _ -> nil
    end
  end

  defp generate_viral_spiral_notification(state, params) do
    with from_id when not is_nil(from_id) <- params["from_id"] do
      player_name = get_player_name_by_id(state.players, from_id)
      "#{player_name} used Viral Spiral power"
    else
      _ -> nil
    end
  end

  # Helper functions
  defp get_player_name_by_id(players, player_id) do
    case Map.get(players, player_id) do
      nil -> "Unknown Player"
      player -> player.name
    end
  end
end
