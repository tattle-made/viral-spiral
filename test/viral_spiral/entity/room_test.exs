defmodule ViralSpiral.Entity.RoomTest do
  alias ViralSpiral.Entity.Room.Changes.OffsetChaos
  alias ViralSpiral.Entity.Room.Changes.ResetUnjoinedPlayers
  alias ViralSpiral.Entity.Room.Changes.StartGame
  alias ViralSpiral.Entity.Change.UndefinedChange
  alias ViralSpiral.Entity.Room.Exceptions.JoinBeforeReserving
  alias ViralSpiral.Entity.Room.Changes.ReserveRoom
  alias ViralSpiral.Entity.Room.Exceptions.IllegalReservation
  alias ViralSpiral.Entity.Room.Changes.JoinRoom
  alias ViralSpiral.Entity.Room.Changes.ChangeCountdown
  alias ViralSpiral.Room.EngineConfig
  alias ViralSpiral.Entity.Change
  alias ViralSpiral.Entity.Room
  use ExUnit.Case

  # describe "deterministic room configs" do
  #   test "communities - yellow, red; affinities - sock, houseboat" do
  #     :rand.seed(:exsss, {1, 8, 12})
  #     room = Room.reserve("hello") |> Room.start(4)

  #     assert room.name == "hello"
  #     assert room.affinities == [:houseboat, :skub]
  #     assert room.communities == [:red, :yellow, :blue]
  #     assert room.chaos == 0
  #     assert room.chaos_counter == 10
  #   end
  # end

  describe "changes" do
    setup do
      room = Room.skeleton()
      %{room: room}
    end

    test "reserve", %{room: room} do
      %Room{} = room = Change.change(room, %ReserveRoom{player_name: "adhiraj"})
      assert room.unjoined_players == ["adhiraj"]

      assert_raise IllegalReservation, fn ->
        Change.change(room, %ReserveRoom{player_name: "aman"})
      end
    end

    test "join", %{room: room} do
      assert_raise JoinBeforeReserving, fn ->
        Change.change(room, %JoinRoom{player_name: "adhiraj"})
      end

      room = %{room | state: :reserved, unjoined_players: ["adhiraj"]}

      room =
        room
        |> Change.change(%JoinRoom{player_name: "farah"})
        |> Change.change(%JoinRoom{player_name: "aman"})
        |> Change.change(%JoinRoom{player_name: "krys"})

      assert room.unjoined_players == ["adhiraj", "farah", "aman", "krys"]
    end

    test "change countdown", %{room: room} do
      room = Change.change(room, %OffsetChaos{offset: +2})
      assert room.chaos == 2

      assert_raise ArithmeticError, fn ->
        Change.change(room, %OffsetChaos{offset: "hello"})
      end
    end

    test "start game", %{room: room} do
      room = Change.change(room, %StartGame{})
      assert room.affinities |> length() != 0
      assert room.communities |> length() != 0
    end

    test "reset unjoined players", %{room: room} do
      room = %{room | unjoined_players: ["a", "b", "c"]}
      room = Change.change(room, %ResetUnjoinedPlayers{})
      assert room.unjoined_players == []
    end

    test "undefined change", %{room: room} do
      assert_raise UndefinedChange, fn ->
        Change.change(room, %{})
      end
    end
  end
end
