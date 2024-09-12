defmodule Fixtures do
  alias ViralSpiral.Room.State.Player
  alias ViralSpiral.Deck.Card
  alias ViralSpiral.Room.State.Turn
  alias ViralSpiral.Room.State.Round
  alias ViralSpiral.Room.State.Room
  alias ViralSpiral.Game.EngineConfig
  # alias ViralSpiral.Game.Score.Room, as: RoomScore

  alias ViralSpiral.Room.State.Root

  def initialized_game() do
    engine_config = %EngineConfig{}

    player_list = [
      Player.new(engine_config) |> Player.set_name("adhiraj"),
      Player.new(engine_config) |> Player.set_name("aman"),
      Player.new(engine_config) |> Player.set_name("krys"),
      Player.new(engine_config) |> Player.set_name("farah")
    ]

    players = Enum.reduce(player_list, %{}, fn player, acc -> Map.put(acc, player.id, player) end)

    round = Round.new(player_list)
    turn = Turn.new(round)

    %Root{
      engine_config: engine_config,
      room: Room.new(),
      players: players,
      round: round,
      turn: turn
    }
  end

  def players() do
    engine_config = %EngineConfig{}

    player_list = [
      Player.new(engine_config) |> Player.set_name("adhiraj"),
      Player.new(engine_config) |> Player.set_name("aman"),
      Player.new(engine_config) |> Player.set_name("krys"),
      Player.new(engine_config) |> Player.set_name("farah")
    ]

    Enum.reduce(player_list, %{}, fn player, acc -> Map.put(acc, player.id, player) end)
  end
end
