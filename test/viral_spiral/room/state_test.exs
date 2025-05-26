defmodule ViralSpiral.Room.StateTest do
  use ExUnit.Case
  alias ViralSpiral.Room.State

  test "identity_stats/0" do
    :rand.seed(:exsss, {123, 80, 96})
    {state, players} = StateFixtures.new_game_with_four_players()
    %{adhiraj: adhiraj, aman: aman, farah: farah, krys: krys} = players

    state =
      state
      |> StateFixtures.update_player(adhiraj, %{
        clout: 5,
        biases: %{blue: 3, red: 1},
        affinities: %{sock: 2, houseboat: -3}
      })
      |> StateFixtures.update_player(aman, %{
        clout: 3,
        biases: %{red: 0, yellow: 2},
        affinities: %{sock: -4, houseboat: 5}
      })
      |> StateFixtures.update_player(farah, %{
        identity: :red,
        clout: 1,
        biases: %{yellow: 0, red: 0},
        affinities: %{sock: 1, houseboat: 0}
      })
      |> StateFixtures.update_player(krys, %{
        clout: 4,
        biases: %{red: 3, yellow: 1},
        affinities: %{sock: 0, houseboat: 0}
      })

    stats = State.identity_stats(state)

    assert %{
             dominant_community: :yellow,
             other_community: :yellow,
             oppressed_community: :red,
             unpopular_affinity: :sock,
             popular_affinity: :houseboat
           } = stats
  end
end
