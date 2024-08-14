defmodule ViralSpiral.Game.State do
  defstruct room_config: nil,
            room: nil,
            player_list: nil,
            player_map: nil,
            room_score: nil,
            player_scores: nil,
            round: nil,
            turn: nil

  @moduledoc """
  Context for the game.

  Rounds and Turns
  round = Round.new(players)
  round_order = Round.order(round)
  During a Round every player gets to draw a card and then take some actions.
  When a round begins, we also start a Turn. Within each Round there's a turn that includes everyone except the person who started the turn.
  """
  alias ViralSpiral.Game.State

  def set_round(%State{} = game, round) do
    %State{game | round: round}
  end

  def set_turn(%State{} = game, turn) do
    %State{game | turn: turn}
  end
end
