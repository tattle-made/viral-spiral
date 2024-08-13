defmodule ViralSpiral.Game do
  defstruct room: nil,
            player_list: nil,
            player_map: nil,
            scores: nil

  @moduledoc """
  Context for the game.

  Rounds and Turns
  round = Round.new(players)
  round_order = Round.order(round)
  During a Round every player gets to draw a card and then take some actions.
  When a round begins, we also start a Turn. Within each Round there's a turn that includes everyone except the person who started the turn.
  """
end
