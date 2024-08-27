defmodule ViralSpiral.Game.State do
  @moduledoc """
  Context for the game.

  Rounds and Turns
  round = Round.new(players)
  round_order = Round.order(round)
  During a Round every player gets to draw a card and then take some actions.
  When a round begins, we also start a Turn. Within each Round there's a turn that includes everyone except the person who started the turn.
  """

  alias ViralSpiral.Room.State.Round
  alias ViralSpiral.Room.State.Room
  alias ViralSpiral.Game.Player
  alias ViralSpiral.Room.State.Player
  alias ViralSpiral.Game.Room
  alias ViralSpiral.Game.RoomConfig
  alias ViralSpiral.Game.State
  alias ViralSpiral.Score.Change

  defstruct room_config: nil,
            room: nil,
            player_list: nil,
            player_map: nil,
            room_score: nil,
            player_scores: nil,
            round: nil,
            turn: nil,
            deck: nil

  # @type t :: %__MODULE__{
  #         room_config: RoomConfig.t(),
  #         room: Room.t(),
  #         player_list: list(Player.t()),
  #         player_map: map(String.t(), Player.t()),
  #         room_score: Room.t(),
  #         player_scores: map(String.t(), Room.t()),
  #         round: Round.t(),
  #         turn: Turn.t(),
  #         deck: Deck.t()
  #       }

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
