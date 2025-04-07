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
    %State{}
    |> then(fn state ->
      %{state | room: Room.start(state.room)}
    end)
  end

  def new_game() do
    room = Room.reserve("test-room") |> Room.start(4)
    State.new(room, ["adhiraj", "krys", "aman", "farah"])
  end

  def player_by_names(%State{} = root) do
    players = root.players

    Map.keys(root.players)
    |> Enum.reduce(%{}, fn player_id, all ->
      Map.put(all, String.to_atom(players[player_id].name), players[player_id])
    end)
  end

  def add_active_card(%State{} = state, player_id, card) do
    player =
      state.players[player_id]
      |> Player.add_active_card(card.id, card.veracity)

    players = Map.put(state.players, player_id, player)
    %{state | players: players}
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
