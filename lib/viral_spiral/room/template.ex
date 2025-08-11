defmodule ViralSpiral.Room.Template do
  @moduledoc """
  Generates template text and provides helper functions for end-game messages and summaries.
  """

  defmodule WorldEndTemplateData do
    @enforce_keys [:bias_data, :affinity_data]
    defstruct bias_data: nil, affinity_data: nil
  end

  defmodule PlayerWinTemplateData do
    @enforce_keys [:winner, :runner_up, :margin, :bias_data, :affinity_data]
    defstruct winner: nil, runner_up: nil, margin: nil, bias_data: nil, affinity_data: nil
  end

  def generate_game_over_message(%WorldEndTemplateData{
        bias_data: bias_data,
        affinity_data: affinity_data
      }) do
    bias_line = generate_bias_line(bias_data)
    affinity_line = generate_affinity_line(affinity_data)

    winner_message = "The world has collapsed into chaos!"
    summary = Enum.join([bias_line, affinity_line], " ")

    [winner_message, summary] |> Enum.join(" ")
  end

  def generate_game_over_message(%PlayerWinTemplateData{
        winner: winner,
        runner_up: runner_up,
        margin: margin,
        bias_data: bias_data,
        affinity_data: affinity_data
      }) do
    margin_line = generate_margin_line(winner, runner_up, margin)
    runner_up_line = generate_runner_up_line(runner_up)
    bias_line = generate_bias_line(bias_data)
    affinity_line = generate_affinity_line(affinity_data)

    winner_message =
      "The world has collapsed into chaos! #{winner.name} has won the game with clout #{winner.clout}!"

    summary = Enum.join([margin_line, runner_up_line, bias_line, affinity_line], " ")

    [winner_message, summary] |> Enum.join(" ")
  end

  # Helper functions to generate text lines
  defp generate_margin_line(winner, runner_up, margin) do
    cond do
      margin >= 5 ->
        "What a landslide! #{winner.name} left everyone in the dust."

      margin >= 2 ->
        "A solid win for #{winner.name}, but #{runner_up && runner_up.name} kept it interesting."

      margin > 0 ->
        "That was close! #{winner.name} just edged out #{runner_up && runner_up.name}."

      true ->
        "A bizarre finish!"
    end
  end

  defp generate_runner_up_line(runner_up) do
    if runner_up do
      "#{runner_up.name} came in second place with clout #{runner_up.clout}."
    else
      "No runner-up this time."
    end
  end

  defp generate_bias_line(%{most_biased_players: most_biased_players, max_bias: _max_bias}) do
    cond do
      most_biased_players == [] ->
        "No one showed much bias this game."

      length(most_biased_players) == 1 ->
        "#{hd(most_biased_players).name} had the most bias. Hope you sleep well tonight, #{hd(most_biased_players).name}!"

      true ->
        names = most_biased_players |> Enum.map(& &1.name) |> Enum.join(", ")
        "It was a bias fest! #{names} all tied for most bias. Hope you all sleep well tonight!"
    end
  end

  defp generate_affinity_line(%{
         most_affinity_players: most_affinity_players,
         max_affinity: _max_affinity
       }) do
    cond do
      most_affinity_players == [] ->
        "No one really leaned into their affinities."

      length(most_affinity_players) == 1 ->
        "#{hd(most_affinity_players).name} was all about those affinities!"

      true ->
        names = most_affinity_players |> Enum.map(& &1.name) |> Enum.join(", ")
        "Affinity overload! #{names} all tied for most affinity!"
    end
  end
end

defmodule ViralSpiral.Room.ActionNotifications do
  @moduledoc """
  Generates notification messages for game actions. Card details are intentionally omitted to avoid revealing gameplay information.
  """

  def pass_card_notification(from_name, to_name) do
    "#{from_name} passed a card to #{to_name}"
  end

  def keep_card_notification(player_name) do
    "#{player_name} kept a card"
  end

  def discard_card_notification(player_name) do
    "#{player_name} discarded a card"
  end

  def initiate_cancel_notification(player_name, target_name) do
    "#{player_name} initiated cancel on #{target_name}"
  end

  def cancel_vote_notification(player_name, vote) do
    vote_text = if vote, do: "voted YES", else: "voted NO"
    "#{player_name} #{vote_text} to cancel"
  end

  def initiate_viral_spiral_notification(player_name) do
    "#{player_name} used Viral Spiral power"
  end
end
