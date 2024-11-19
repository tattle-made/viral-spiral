defmodule ViralSpiral.Room.State do
  @moduledoc """
  Entire Game's state.

  Encapsulates all Entities of Viral Spiral.

  Rounds and Turns
  round = Round.new(players)
  round_order = Round.order(round)
  During a Round every player gets to draw a card and then take some actions.
  When a round begins, we also start a Turn. Within each Round there's a turn that includes everyone except the person who started the turn.
  """

  alias ViralSpiral.Gameplay.Factory
  alias ViralSpiral.Entity.Deck
  alias ViralSpiral.Entity.Room
  alias ViralSpiral.Entity.Turn
  alias ViralSpiral.Entity.Round
  alias ViralSpiral.Entity.Room
  alias ViralSpiral.Entity.Player
  alias ViralSpiral.Room.State
  alias ViralSpiral.Entity.Change

  defstruct room: nil,
            players: [],
            round: nil,
            turn: nil,
            deck: nil

  @type t :: %__MODULE__{
          room: Room.t(),
          players: %{String.t() => Player.t()},
          round: Round.t(),
          turn: Turn.t(),
          deck: Deck.t()
        }

  def empty() do
    %State{}
  end

  def new(%Room{} = room, player_names) when is_list(player_names) do
    players =
      player_names
      |> Enum.map(fn player_name ->
        Factory.new_player_for_room(room) |> Player.set_name(player_name)
      end)
      |> Enum.reduce(%{}, fn player, acc -> Map.put(acc, player.id, player) end)

    round = Round.new(players)
    turn = Turn.new(round)
    deck = Factory.new_deck(room)

    %State{
      room: room,
      players: players,
      round: round,
      turn: turn,
      deck: deck
    }
  end

  def set_round(%State{} = game, round) do
    %{game | round: round}
  end

  def set_room(%State{} = State, room) do
    %{State | room: room}
  end

  def set_turn(%State{} = game, turn) do
    %{game | turn: turn}
  end

  # @spec apply_changes(list(Change.t())) ::
  #         list({:ok, message :: String.t()} | {:error, reason :: String.t()})
  def apply_changes(state, changes) do
    Enum.reduce(changes, state, fn change, state ->
      data = get_target(state, elem(change, 0))
      change_inst = elem(change, 2)
      new_value = apply_change(data, state, change_inst)
      put_target(state, new_value)
    end)
  end

  defdelegate apply_change(change, state, opts), to: Change

  defp get_target(%State{} = state, %Player{id: id}) do
    state.players[id]
  end

  defp get_target(%State{} = state, %Turn{} = turn) do
    state.turn
  end

  defp get_target(%State{} = state, %Round{} = round) do
    state.round
  end

  defp get_target(%State{} = state, %Deck{} = deck) do
    state.deck
  end

  defp get_target(%State{} = state, %State{} = _state_again) do
    state
  end

  @doc """
  Generalized way to get a nested entity from state.

  The entity needs to implement `Change` protocol for this to be meaningful.

  get(state, "players")
  get(state, "players[:id].hand")
  get(state, "players[:id].hand[2]")
  get(state, "turn.round.current_player")
  """
  defp get(%State{} = _state, _key) do
  end

  defp put_target(%State{} = state, %Player{id: id} = player) do
    updated_player_map = Map.put(state.players, id, player)
    Map.put(state, :players, updated_player_map)
  end

  defp put_target(%State{} = state, %Round{} = round) do
    Map.put(state, :round, round)
  end

  defp put_target(%State{} = state, %Turn{} = turn) do
    Map.put(state, :turn, turn)
  end

  defp put_target(%State{} = state, %Deck{} = deck) do
    Map.put(state, :deck, deck)
  end

  def current_turn_player(%State{} = state), do: state.players[state.turn.current]

  def current_round_player(%State{} = state),
    do: state.players[Round.current_player_id(state.round)]
end
