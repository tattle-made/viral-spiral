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

  require IEx
  alias ViralSpiral.Entity.DynamicCard
  alias ViralSpiral.Room.DrawConstraints
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
  defstruct room: nil,
            players: %{},
            round: Round.skeleton(),
            turn: Turn.skeleton(),
            turns: %{},
            deck: nil,
            articles: %{},
            power_viralspiral: nil,
            power_check_source: CheckSource.new(),
            power_cancel_player: %PowerCancelPlayer{},
            dynamic_card: DynamicCard.skeleton()

  @type t :: %__MODULE__{
          deck: Deck.t(),
          room: Room.t(),
          players: %{String.t() => Player.t()},
          round: Round.t(),
          turn: Turn.t(),
          articles: map(),
          power_check_source: CheckSource.t(),
          power_viralspiral: PowerViralSpiral.t(),
          power_cancel_player: PowerCancelPlayer.t(),
          dynamic_card: DynamicCard.t()
        }

  def skeleton(opts \\ []) do
    state = %State{}
    %{state | room: Room.skeleton(opts)}
  end

  def setup(%State{} = state) do
    room = state.room

    if length(room.unjoined_players) == 0,
      do: raise("Can not initialize state when no players have joined")

    players =
      room.unjoined_players
      |> Enum.map(fn player_name ->
        Factory.new_player_for_room(room) |> Player.set_name(player_name)
      end)
      |> Enum.reduce(%{}, fn player, acc -> Map.put(acc, player.id, player) end)

    round = Round.new(players)
    turn = Turn.new(round)

    card_attrs = State.card_attrs(state)
    deck = Deck.skeleton(card_attrs)

    %{state | room: room, players: players, round: round, turn: turn, deck: deck}
  end

  def set_round(%State{} = game, round) do
    %{game | round: round}
  end

  def set_room(%State{} = state, room) do
    %{state | room: room}
  end

  def set_turn(%State{} = game, turn) do
    %{game | turn: turn}
  end

  def draw_constraints(%State{} = state) do
    curr_player = current_round_player(state)

    %DrawConstraints{
      chaos: state.room.chaos,
      total_tgb: state.room.chaos_counter,
      biases: state.room.communities,
      affinities: state.room.affinities,
      current_player: %{identity: curr_player.identity}
    }
  end

  def card_attrs(%State{} = state) do
    []
    |> Keyword.put(:affinities, state.room.affinities)
    |> Keyword.put(:biases, state.room.communities)
  end

  # @spec apply_changes(list(Change.t())) ::
  #         list({:ok, message :: String.t()} | {:error, reason :: String.t()})
  def apply_changes(state, changes) do
    Enum.reduce(changes, state, fn change, state ->
      # require IEx
      # IEx.pry()
      data = get_target(state, elem(change, 0))
      change_desc = elem(change, 1)
      new_value = change(data, change_desc)
      put_target(state, new_value)
    end)
  end

  defdelegate change(change, change_desc), to: Change

  defp get_target(%State{} = state, %Room{} = _room) do
    state.room
  end

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

  defp get_target(%State{} = state, %PowerCancelPlayer{} = power_cancel_player) do
    state.power_cancel_player
  end

  defp get_target(%State{} = state, %DynamicCard{}) do
    state.dynamic_card
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

  defp put_target(%State{} = state, %PowerCancelPlayer{} = power_cancel_player) do
    Map.put(state, :power_cancel_player, power_cancel_player)
  end

  defp put_target(%State{} = state, %Room{} = room) do
    Map.put(state, :room, room)
  end

  defp put_target(%State{} = state, %DynamicCard{} = dynamic_card) do
    Map.put(state, :dynamic_card, dynamic_card)
  end

  @spec current_round_player(State.t()) :: Player.t()
  def current_turn_player(%State{} = state), do: state.players[state.turn.current]

  def current_round_player(%State{} = state),
    do: state.players[Round.current_player_id(state.round)]

  @spec active_card(State.t(), String.t(), integer()) :: tuple() | nil
  def active_card(%State{} = state, player_id, ix) do
    case state.players[player_id].active_cards |> Enum.at(ix) do
      %Sparse{} = sparse_card -> sparse_card
      nil -> nil
    end
  end

  def identity_stats(%State{} = state) do
    players = Map.keys(state.players) |> Enum.map(&state.players[&1])

    current_player_id = State.current_turn_player(state).id
    player_community = state.players[current_player_id].identity

    # IO.inspect(current_player_id, label: "current player id")
    # IO.inspect(player_community, label: "player_community")

    # dominant community
    # currently defined as identity of the player with the largest clout
    dominant_community =
      players
      |> Enum.sort(&(&1.clout >= &2.clout))
      |> hd
      |> Map.get(:identity)

    other_community =
      state.room.communities
      |> Enum.filter(&(&1 != State.current_turn_player(state).identity))
      |> Enum.shuffle()
      |> hd

    # currently defined as the identity of the player with lowest clout
    oppressed_community =
      players
      |> Enum.sort(&(&1.clout <= &2.clout))
      |> hd
      |> Map.get(:identity)

    affinity_count_map =
      state.room.affinities
      |> Enum.reduce(%{}, fn x, acc -> Map.put(acc, x, 0) end)

    affinity_cum =
      Map.keys(state.players)
      |> Enum.map(&state.players[&1].affinities)
      |> Enum.flat_map(fn x -> x end)
      |> Enum.reduce(affinity_count_map, fn {aff, cnt}, acc ->
        Map.put(acc, aff, acc[aff] + cnt)
      end)

    unpopular_affinity =
      affinity_cum
      |> Enum.min_by(fn {_k, v} -> v end)
      |> elem(0)

    popular_affinity =
      affinity_cum
      |> Enum.max_by(fn {_k, v} -> v end)
      |> elem(0)

    %{
      dominant_community: dominant_community,
      other_community: other_community,
      oppressed_community: oppressed_community,
      unpopular_affinity: unpopular_affinity,
      popular_affinity: popular_affinity,
      player_community: player_community
    }
  end

  @doc """
  Checks if the game is over and returns status

  Returns the following values
    - {:no_over} if the game is not over yet
    - {:over, :player, "player_id"} if a player has won
    - {:over, :world} if the world has collapsed
  """
  def game_over_status(%State{} = state) do
    chaos_threshold_crossed? = if state.room.chaos >= 10, do: true, else: false

    winners =
      state.players
      |> Enum.filter(fn {_id, player} -> player.clout >= 10 end)

    # todo check for illegal state of >1 condition
    player_won? =
      case winners |> length() do
        0 -> false
        1 -> true
      end

    winner_id =
      case player_won? do
        true -> winners |> hd |> elem(1) |> Map.get(:id)
        false -> nil
      end

    cond do
      chaos_threshold_crossed? -> {:over, :world}
      player_won? -> {:over, :player, winner_id}
      true -> {:no_over}
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
