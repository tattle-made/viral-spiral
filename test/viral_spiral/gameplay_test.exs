defmodule ViralSpiral.GameTest do
  @moduledoc """
  A step by step recreation of every step of a game.

  We only do 2 rounds for brevity.
  """
  alias ViralSpiral.Room.State.Player
  alias ViralSpiral.Room.State.Turn
  alias ViralSpiral.Room.State.Round
  alias ViralSpiral.Room.State.Root
  alias ViralSpiral.Room.State.Room
  alias ViralSpiral.Game
  use ExUnit.Case

  test "Play a round" do
    :rand.seed(:exsss, {1, 87, 90})

    # Player One creates a room and gets its link to share with others
    room = Room.new()
    assert room.chaos_counter != nil
    assert room.id != nil
    assert room.state == :uninitialized
    assert room.name != nil
    assert room.name == "basic-venus"

    # Start a game with 4 Players
    room = Room.start(room, 4)
    assert room.affinities != []
    assert room.communities != []
    assert room.state == :running

    root = Root.new(room, ["adhiraj", "krys", "aman", "farah"])
    assert match?(%Root{players: %{}, round: %Round{}, turn: %Turn{}}, root)

    round = root.round
    turn = root.turn

    player_a = Enum.at(round.order, 0)
    player_b = Enum.at(round.order, 1)
    player_c = Enum.at(round.order, 2)
    player_d = Enum.at(round.order, 3)

    # draw a card and pass it and check state at every point
    assert match?(
             %Root{
               players: %{
                 ^player_a => %Player{clout: 0},
                 ^player_b => %Player{clout: 0, biases: %{yellow: 0}}
               }
             },
             root
           )
  end
end
