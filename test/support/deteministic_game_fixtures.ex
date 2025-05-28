defmodule DeteministicGameFixtures do
  alias ViralSpiral.Entity.Turn
  alias ViralSpiral.Entity.Round
  alias ViralSpiral.Entity.Player
  alias ViralSpiral.Entity.Room
  alias ViralSpiral.Room.State

  def new() do
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
      deck: %{
        store: %{},
        available_cards: %{},
        dealt_cards: %{},
        article_store: %{}
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
end
