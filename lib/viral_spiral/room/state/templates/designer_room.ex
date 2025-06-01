defmodule ViralSpiral.Room.State.Templates.DesignerRoom do
  alias ViralSpiral.Room.Actions
  alias ViralSpiral.Room.Reducer
  alias ViralSpiral.Room.State

  def make(room_name) do
    State.skeleton(room_name: room_name)
    |> Reducer.reduce(Actions.reserve_room(%{player_name: "adhiraj"}))
    |> Reducer.reduce(Actions.join_room(%{player_name: "aman"}))
    |> Reducer.reduce(Actions.join_room(%{player_name: "farah"}))
    |> Reducer.reduce(Actions.join_room(%{player_name: "krys"}))
    |> Reducer.reduce(Actions.start_game())
    |> Reducer.reduce(Actions.draw_card())
  end
end
