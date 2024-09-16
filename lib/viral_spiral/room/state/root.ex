defmodule ViralSpiral.Room.State.Root do
  @moduledoc """
  Context for the game.

  Rounds and Turns
  round = Round.new(players)
  round_order = Round.order(round)
  During a Round every player gets to draw a card and then take some actions.
  When a round begins, we also start a Turn. Within each Round there's a turn that includes everyone except the person who started the turn.
  """

  alias ViralSpiral.Room.RoomConfig
  alias ViralSpiral.Room.State.Turn
  alias ViralSpiral.Canon.Deck
  alias ViralSpiral.Room.State.Round
  alias ViralSpiral.Room.State.Room
  alias ViralSpiral.Room.State.Player
  alias ViralSpiral.Room.State.Root
  alias ViralSpiral.Room.State.Change

  defstruct room_config: nil,
            room: nil,
            players: [],
            round: nil,
            turn: nil,
            deck: nil

  @type t :: %__MODULE__{
          room_config: RoomConfig.t(),
          room: Room.t(),
          players: list(Player.t()),
          round: Round.t()
          # turn: Turn.t(),
          # deck: Deck.t()
        }

  def set_round(%Root{} = game, round) do
    %{game | round: round}
  end

  def set_turn(%Root{} = game, turn) do
    %{game | turn: turn}
  end

  # @spec apply_changes(list(Change.t())) ::
  #         list({:ok, message :: String.t()} | {:error, reason :: String.t()})
  def apply_changes(state, changes) do
    Enum.reduce(changes, state, fn change, state ->
      # require IEx
      # IEx.pry()
      data = get_target(state, elem(change, 0))
      change_inst = elem(change, 1)
      new_value = apply_change(data, state, change_inst)
      put_target(state, new_value)
    end)
  end

  defdelegate apply_change(change, state, opts), to: Change

  def get_target(%Root{} = state, %Player{id: id}) do
    state.players[id]
  end

  def get_target(%Root{} = state, %Turn{} = turn) do
    state.turn
  end

  def get_target(%Root{} = state, %Round{} = round) do
    state.round
  end

  def get_target(%Root{} = state, %Root{} = _state_again) do
    state
  end

  def put_target(%Root{} = state, %Player{id: id} = player) do
    updated_player_map = Map.put(state.players, id, player)
    Map.put(state, :players, updated_player_map)
  end

  def put_target(%Root{} = state, %Round{} = round) do
    Map.put(state, :round, round)
  end

  def put_target(%Root{} = state, %Turn{} = turn) do
    Map.put(state, :turn, turn)
  end
end
