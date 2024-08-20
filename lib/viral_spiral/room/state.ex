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
  alias ViralSpiral.Score.Change

  def set_round(%State{} = game, round) do
    %State{game | round: round}
  end

  def set_turn(%State{} = game, turn) do
    %State{game | turn: turn}
  end

  # @spec apply_changes(list(Change.t())) ::
  #         list({:ok, message :: String.t()} | {:error, reason :: String.t()})
  def apply_changes(state, changes) do
    # Enum.reduce(changes, [], &(&2 ++ [apply_change(elem(&1, 0), elem(&1, 1))]))
    _results = Enum.map(changes, &apply(elem(&1, 0), elem(&1, 1)))
    # new_state = Enum.reduce(results, state, &)

    # results = Enum.reduce...
    # state = Enum.reduce(results, state, &Map.put(&1.id, &1.value))
  end

  defdelegate apply_change(change, opts), to: Change

  # @doc """
  # Change various components of state.

  # round, turn, room, card, player_score
  # """
  # def apply(state, change) do
  #   case change do
  #     %{id: id, value: value}
  #   end
  # end
end
