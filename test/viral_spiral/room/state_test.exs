defmodule ViralSpiral.Room.StateTest do
  use ExUnit.Case
  alias ViralSpiral.Room.StateTransformation
  alias ViralSpiral.Room.State
  alias ViralSpiral.Room.Template

  test "identity_stats/0" do
    :rand.seed(:exsss, {123, 80, 96})
    {state, players} = StateFixtures.new_game_with_four_players()
    %{adhiraj: adhiraj, aman: aman, farah: farah, krys: krys} = players

    state =
      state
      |> StateTransformation.update_room(%{affinities: [:sock, :houseboat]})
      |> StateTransformation.update_player(adhiraj, %{
        clout: 5,
        biases: %{blue: 3, red: 1},
        affinities: %{sock: 2, houseboat: -3}
      })
      |> StateTransformation.update_player(aman, %{
        clout: 3,
        biases: %{red: 0, yellow: 2},
        affinities: %{sock: -4, houseboat: 5}
      })
      |> StateTransformation.update_player(farah, %{
        identity: :red,
        clout: 1,
        biases: %{yellow: 0, red: 0},
        affinities: %{sock: 1, houseboat: 0}
      })
      |> StateTransformation.update_player(krys, %{
        clout: 4,
        biases: %{red: 3, yellow: 1},
        affinities: %{sock: 0, houseboat: 0}
      })

    stats = State.identity_stats(state)

    assert %{
             dominant_community: :blue,
             other_community: :red,
             oppressed_community: :red,
             unpopular_affinity: :sock,
             popular_affinity: :houseboat,
             player_community: :blue
           } = stats
  end

  describe "game_over_status/1" do
    setup do
      :rand.seed(:exsss, {123, 80, 96})
      {state, players} = StateFixtures.new_game_with_four_players()
      %{state: state, players: players}
    end

    test "no_over", %{state: state} do
      assert {:no_over} = State.game_over_status(state)
    end

    test "world collapse", %{state: state} do
      state = state |> StateTransformation.update_room(%{chaos: 10})

      assert {:over, :world,
              %Template.WorldEndTemplateData{bias_data: bias_data, affinity_data: affinity_data}} =
               State.game_over_status(state)

      assert %{most_biased_players: _, max_bias: _} = bias_data
      assert %{most_affinity_players: _, max_affinity: _} = affinity_data
    end

    test "player win", %{state: state, players: players} do
      %{adhiraj: adhiraj} = players

      state = state |> StateTransformation.update_player(adhiraj, %{clout: 10})

      assert {:over, :player, ^adhiraj,
              %Template.PlayerWinTemplateData{
                winner: winner,
                runner_up: runner_up,
                margin: margin,
                bias_data: bias_data,
                affinity_data: affinity_data
              }} = State.game_over_status(state)

      assert winner.id == adhiraj
      assert winner.clout == 10
      assert is_integer(margin)
      assert %{most_biased_players: _, max_bias: _} = bias_data
      assert %{most_affinity_players: _, max_affinity: _} = affinity_data
    end
  end
end
