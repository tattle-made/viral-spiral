defmodule Fixtures do
  alias ViralSpiral.Game.Score.Player
  alias ViralSpiral.Game.Turn
  alias ViralSpiral.Game.Round
  alias ViralSpiral.Game.Room
  alias ViralSpiral.Game.RoomConfig
  alias ViralSpiral.Game.Score.Player, as: PlayerScore
  # alias ViralSpiral.Game.Score.Room, as: RoomScore
  alias ViralSpiral.Game.Player
  alias ViralSpiral.Game.State

  def initialized_game() do
    room_config = %RoomConfig{}

    player_list = [
      Player.new(room_config) |> Player.set_name("adhiraj"),
      Player.new(room_config) |> Player.set_name("aman"),
      Player.new(room_config) |> Player.set_name("krys"),
      Player.new(room_config) |> Player.set_name("farah")
    ]

    players = Enum.reduce(player_list, %{}, fn player, acc -> Map.put(acc, player.id, player) end)

    round = Round.new(player_list)
    turn = Turn.new(round)

    %State{
      room_config: room_config,
      room: Room.new(),
      player_map: players,
      player_list: player_list,
      round: round,
      turn: turn,
      # room_score: RoomScore.new(),
      player_scores: Enum.map(player_list, &PlayerScore.new(&1, room_config))
    }
  end
end
