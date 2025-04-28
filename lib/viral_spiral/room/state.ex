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

  alias ViralSpiral.Entity.PowerCancelPlayer
  alias ViralSpiral.Canon.Card.Sparse
  alias ViralSpiral.Entity.CheckSource
  alias ViralSpiral.Entity.Article
  alias ViralSpiral.Entity.PowerViralSpiral
  alias ViralSpiral.Room.Factory
  alias ViralSpiral.Entity.Deck
  alias ViralSpiral.Entity.Room
  alias ViralSpiral.Entity.Turn
  alias ViralSpiral.Entity.Round
  alias ViralSpiral.Entity.Room
  alias ViralSpiral.Entity.Player
  alias ViralSpiral.Room.State
  alias ViralSpiral.Entity.Change

  @derive {Inspect, limit: 2}
  defstruct room: Room.skeleton(),
            players: %{},
            round: Round.skeleton(),
            turn: Turn.skeleton(),
            turns: %{},
            # deck: Deck.skeleton(),
            deck: nil,
            articles: %{},
            power_viralspiral: nil,
            power_check_source: CheckSource.new(),
            power_cancel_player: %PowerCancelPlayer{}

  @type t :: %__MODULE__{
          deck: Deck.t(),
          room: Room.t(),
          players: %{String.t() => Player.t()},
          round: Round.t(),
          turn: Turn.t(),
          articles: map(),
          power_check_source: CheckSource.t(),
          power_viralspiral: PowerViralSpiral.t(),
          power_cancel_player: PowerCancelPlayer.t()
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
      deck: deck,
      articles: %{}
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
      # require IEx
      # IEx.pry()
      data = get_target(state, elem(change, 0))
      change_desc = elem(change, 1)
      new_value = apply_change(data, change_desc)
      put_target(state, new_value)
    end)
  end

  defdelegate apply_change(change, change_desc), to: Change

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

  defp get_target(%State{} = state, %PowerViralSpiral{} = power) do
  end

  defp get_target(%State{} = state, %CheckSource{} = _check_source) do
    state.power_check_source
  end

  defp get_target(%State{} = state, %Article{id: id} = article) do
    state.articles[id]
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

  defp put_target(%State{} = state, %Article{id: id} = article) do
    updated_article_map = Map.put(state.articles, id, article)
    Map.put(state, :articles, updated_article_map)
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

  defp put_target(%State{} = state, %PowerViralSpiral{} = power) do
    Map.put(state, :power_viralspiral, power)
  end

  defp put_target(%State{} = state, %CheckSource{} = check_source) do
    Map.put(state, :power_check_source, check_source)
  end

  @spec current_round_player(State.t()) :: Player.t()
  def current_turn_player(%State{} = state), do: state.players[state.turn.current]

  def current_round_player(%State{} = state),
    do: state.players[Round.current_player_id(state.round)]

  @spec active_card(State.t(), String.t(), integer()) :: tuple() | nil
  def active_card(%State{} = state, player_id, ix) do
    case state.players[player_id].active_cards |> Enum.at(ix) do
      {id, veracity, _headline} -> Sparse.new({id, veracity})
      nil -> nil
    end
  end

  # defimpl Inspect do
  #   import Inspect.Algebra
  #   alias Inspect.Opts

  #   def inspect(state, _opts) do
  #     players =
  #       Map.keys(state.players)
  #       |> Enum.map(fn id ->
  #         player = state.players[id]

  #         current_round = if player == State.current_round_player(state), do: "CR", else: ""
  #         current_turn = if player == State.current_turn_player(state), do: "CT", else: ""

  #         header = "#{player.id} : #{player.name} : #{player.identity} : #{player.clout} "

  #         affinities =
  #           Map.keys(player.affinities)
  #           |> Enum.map(&"#{&1} : #{player.affinities[&1]}")
  #           |> Enum.join(" | ")

  #         biases =
  #           Map.keys(player.biases)
  #           |> Enum.map(&"#{&1} : #{player.biases[&1]}")
  #           |> Enum.join(" | ")

  #         active_cards =
  #           player.active_cards
  #           |> Enum.map(&"#{elem(&1, 0)} : #{elem(&1, 1)}")
  #           |> IO.iodata_to_binary()

  #         # hand =
  #         #   player.hand
  #         #   |> Enum.map(&"#{elem(&1, 0)} : #{elem(&1, 1)}")
  #         #   |> IO.iodata_to_binary()

  #         [current_round <> current_turn, header, affinities, biases, active_cards]
  #         |> Enum.join("\n")
  #         |> IO.iodata_to_binary()

  #         # {player.id, player.name, player.clout, player.affinities, player.biases}
  #         # |> IO.iodata_to_binary()
  #       end)
  #       |> Enum.intersperse(line())
  #       |> Enum.intersperse(line())
  #       |> concat()

  #     concat([
  #       nest(doc({state.room.id, state.room.name, state.room.chaos_counter}), 4),
  #       line(),
  #       players
  #     ])
  #   end

  #   def doc(entity) do
  #     to_doc(entity, %Opts{pretty: true})
  #   end

  #   def linebr() do
  #     concat([
  #       String.duplicate("_", 50),
  #       line()
  #     ])
  #   end
  # end
end
