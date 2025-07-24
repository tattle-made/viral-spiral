defmodule ViralSpiral.Room.TemplateTest do
  use ExUnit.Case
  alias ViralSpiral.Room.Template
  alias ViralSpiral.Room.StateTransformation
  alias ViralSpiral.Room.State

  setup do
    :rand.seed(:exsss, {123, 456, 789})
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

    %{state: state, players: players}
  end

  test "returns world collapse message when chaos >= 10", %{state: state} do
    state = state |> StateTransformation.update_room(%{chaos: 10})
    {:over, :world, data} = State.game_over_status(state)
    result = Template.generate_game_over_message(data)

    assert is_binary(result) or is_map(result)
    assert String.contains?(result, "The world has collapsed into chaos!")
  end

  test "returns winner message when player wins", %{state: state, players: players} do
    %{adhiraj: adhiraj} = StateTransformation.player_id_by_names(state)
    state = state |> StateTransformation.update_player(adhiraj, %{clout: 10})
    {:over, :player, _id, data} = State.game_over_status(state)
    result = Template.generate_game_over_message(data)

    assert is_binary(result) or is_map(result)
    assert String.contains?(result, "adhiraj")
    assert String.contains?(result, "has won the game")
  end
end
