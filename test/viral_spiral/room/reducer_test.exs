defmodule ViralSpiral.Room.ReducerTest do
  alias ViralSpiral.Room.Actions
  alias ViralSpiral.Room.Reducer
  alias ViralSpiral.Room.State
  alias ViralSpiral.Entity.Room
  use ExUnit.Case

  setup do
    :rand.seed(:exsss, {12356, 123_534, 345_345})

    room = Room.reserve("test-room") |> Room.start(4)
    state = State.new(room, ["adhiraj", "krys", "aman", "farah"])

    %{state: state}
  end

  @tag timeout: :infinity
  test "draw_card", %{state: state} do
    # IO.inspect(state.room)
    Reducer.reduce(state, Actions.draw_card())
  end
end
