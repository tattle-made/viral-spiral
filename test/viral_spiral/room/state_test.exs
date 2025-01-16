defmodule ViralSpiral.Room.StateTest do
  alias ViralSpiral.Game.State
  use ExUnit.Case

  describe "card" do
    setup do
      state = %State{
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
          order: ["player_jkl", "player_ghi", "player_def", "player_abc"],
          count: 4,
          current: 0,
          skip: nil
        },
        turn: %Turn{
          card: nil,
          current: "player_jkl",
          pass_to: ["player_abc", "player_def", "player_ghi"]
        }
      }

      state = %{state | deck: Factory.new_deck(state.room)}

      %{state: state}
    end
  end
end
