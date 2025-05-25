defmodule StateFixtures do
  alias ViralSpiral.Entity.Turn
  alias ViralSpiral.Entity.Round
  alias ViralSpiral.Entity.Player
  alias ViralSpiral.Canon.Card.Sparse
  alias ViralSpiral.Room.State
  alias ViralSpiral.Entity.Room

  def set_chaos(%State{} = root, chaos) do
    room = root.room
    new_room = %{room | chaos: chaos}
    Map.put(root, :room, new_room)
  end

  def player_by_names(%State{} = state) do
    players = state.players

    Map.keys(state.players)
    |> Enum.reduce(%{}, fn player_id, all ->
      Map.put(all, String.to_atom(players[player_id].name), players[player_id])
    end)
  end

  def player_id_by_names(%State{} = state) do
    players = state.players

    Map.keys(state.players)
    |> Enum.reduce(%{}, fn player_id, all ->
      Map.put(all, String.to_atom(players[player_id].name), player_id)
    end)
  end

  def active_cards(%State{} = state, player_id) do
    state.players[player_id].active_cards
  end

  @spec active_card(State.t(), String.t(), integer()) :: tuple() | nil
  def active_card(%State{} = state, player_id, ix) do
    case state.players[player_id].active_cards |> Enum.at(ix) do
      {id, veracity} -> Sparse.new({id, veracity})
      nil -> nil
    end
  end

  def update_round(%State{} = state, attrs) do
    state = put_in(state.round.order, attrs[:order] || state.round.order)
    state = put_in(state.round.current, attrs[:current] || state.round.current)
    state
  end

  def update_turn(%State{} = state, attrs) do
    state = put_in(state.turn.current, attrs[:current] || state.turn.current)
    state = put_in(state.turn.pass_to, attrs[:pass_to] || state.round.pass_to)
    state
  end

  def update_player(%State{} = state, player_id, attrs) do
    player = state.players[player_id]
    player = put_in(player.active_cards, attrs[:active_cards] || player.active_cards)
    state = put_in(state.players[player_id], player)
    state
  end

  def new_game() do
    %State{
      room: %Room{
        id: "room_abc",
        name: "crazy-house-3213",
        state: :running,
        unjoined_players: [],
        affinities: [:skub, :houseboat],
        communities: [:red, :yellow, :blue],
        chaos: 0,
        chaos_counter: 10,
        volatality: :medium
      },
      players: %{
        "player_abc" => %Player{
          id: "player_abc",
          name: "farah",
          biases: %{yellow: 0, blue: 0},
          affinities: %{skub: 0, houseboat: 0},
          clout: 0,
          identity: :red,
          hand: [],
          active_cards: []
        },
        "player_def" => %Player{
          id: "player_def",
          name: "aman",
          biases: %{red: 0, blue: 0},
          affinities: %{skub: 0, houseboat: 0},
          clout: 0,
          identity: :yellow,
          hand: [],
          active_cards: []
        },
        "player_ghi" => %Player{
          id: "player_ghi",
          name: "krys",
          biases: %{yellow: 0, blue: 0},
          affinities: %{skub: 0, houseboat: 0},
          clout: 0,
          identity: :red,
          hand: [],
          active_cards: []
        },
        "player_jkl" => %Player{
          id: "player_jkl",
          biases: %{yellow: 0, blue: 0},
          affinities: %{skub: 0, houseboat: 0},
          clout: 0,
          name: "adhiraj",
          identity: :red,
          hand: [],
          active_cards: []
        }
      },
      round: %Round{
        order: ["player_abc", "player_def", "player_ghi", "player_jkl"],
        count: 4,
        current: 0,
        skip: nil
      },
      turn: %Turn{
        current: "player_abc",
        pass_to: ["player_def", "player_ghi", "player_jkl"],
        path: []
      }
    }
  end

  def new_game_with_four_players() do
    room =
      Room.skeleton()
      |> Room.join("adhiraj")
      |> Room.set_state(:reserved)
      |> Room.join("aman")
      |> Room.join("farah")
      |> Room.join("krys")
      |> Room.start()

    state = %State{room: room}
    state = State.setup(state)
    state = %{state | room: room |> Room.reset_unjoined_players()}
    players = player_id_by_names(state)

    {state, players}
  end
end
