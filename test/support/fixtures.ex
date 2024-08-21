defmodule Fixtures do
  alias ViralSpiral.Deck.Card
  alias ViralSpiral.Game.Score.Player
  alias ViralSpiral.Room.State.Turn
  alias ViralSpiral.Room.State.Round
  alias ViralSpiral.Room.State.Room
  alias ViralSpiral.Game.RoomConfig
  alias ViralSpiral.Room.State.Player, as: PlayerScore
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

    player_score_list =
      Enum.map(
        player_list,
        &(Map.new() |> Map.put(:id, &1.id) |> Map.put(:score, PlayerScore.new(&1, room_config)))
      )

    player_score_map =
      Enum.reduce(player_score_list, %{}, fn player, acc ->
        Map.put(acc, player.id, player.score)
      end)

    %State{
      room_config: room_config,
      room: Room.new(),
      player_map: players,
      player_list: player_list,
      round: round,
      turn: turn,
      # room_score: RoomScore.new(),
      player_scores: player_score_map
    }
  end

  def card_affinity() do
    Card.new(:affinity)
  end

  def player_list() do
    room_config = %RoomConfig{}

    [
      Player.new(room_config) |> Player.set_name("adhiraj"),
      Player.new(room_config) |> Player.set_name("aman"),
      Player.new(room_config) |> Player.set_name("krys"),
      Player.new(room_config) |> Player.set_name("farah")
    ]
  end
end
