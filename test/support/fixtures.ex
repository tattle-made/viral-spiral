defmodule Fixtures do
  alias ViralSpiral.Entity.Room
  alias ViralSpiral.Entity.Player
  alias ViralSpiral.Deck.Card
  alias ViralSpiral.Entity.Turn
  alias ViralSpiral.Entity.Round
  alias ViralSpiral.Entity.Room
  # alias ViralSpiral.Game.Score.Room, as: RoomScore

  alias ViralSpiral.Room.State

  def initialized_game() do
    room = Room.reserve("test-room") |> Room.start(4)
    State.new(room, ["adhiraj", "krys", "aman", "farah"])
  end

  def new_game() do
    room = Room.reserve("test-room") |> Room.start(4)
    State.new(room, ["adhiraj", "krys", "aman", "farah"])
  end

  def new_round() do
    %Round{
      order: ["player_abc", "player_def", "player_ghi", "player_jkl"],
      count: 4,
      current: 0,
      skip: nil
    }
  end
end
