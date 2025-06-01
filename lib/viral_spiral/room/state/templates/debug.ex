defmodule ViralSpiral.Room.State.Templates.Debug do
  alias ViralSpiral.Room.Actions
  alias ViralSpiral.Room.Reducer
  alias ViralSpiral.Room.StateTransformation
  alias ViralSpiral.Room.State

  def make(room_name) do
    game_with_specified_card_draw_round_turn(room_name)
  end

  defp game_with_specified_card_draw_round_turn(room_name) do
    state =
      State.skeleton(room_name: room_name)
      |> Reducer.reduce(Actions.reserve_room(%{player_name: "adhiraj"}))
      |> Reducer.reduce(Actions.join_room(%{player_name: "aman"}))
      |> Reducer.reduce(Actions.join_room(%{player_name: "farah"}))
      |> Reducer.reduce(Actions.join_room(%{player_name: "krys"}))
      |> Reducer.reduce(Actions.start_game())

    players = StateTransformation.player_id_by_names(state)
    %{adhiraj: adhiraj, aman: aman, farah: farah, krys: krys} = players

    sparse_card = StateTransformation.draw_card(state, {:affinity, false, :sock})

    state
    |> StateTransformation.update_player(adhiraj, %{affinities: %{sock: 5, skub: 0}})
    |> StateTransformation.update_player(aman, %{affinities: %{sock: 2, skub: 0}})
    |> StateTransformation.update_player(farah, %{affinities: %{sock: 2, skub: 0}})
    |> StateTransformation.update_player(krys, %{affinities: %{sock: -1, skub: 4}})
    |> StateTransformation.update_round(%{order: [adhiraj, aman, krys, farah]})
    |> StateTransformation.update_turn(%{current: adhiraj, pass_to: [aman, krys, farah]})
    |> StateTransformation.update_player(adhiraj, %{active_cards: [sparse_card]})
  end
end
