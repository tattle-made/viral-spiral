defmodule ViralSpiral.Entity.RoomTest do
  alias ViralSpiral.Room.EngineConfig
  alias ViralSpiral.Room.ChangeDescriptions
  alias ViralSpiral.Entity.Change
  alias ViralSpiral.Entity.Room
  use ExUnit.Case

  describe "deterministic room configs" do
    test "communities - yellow, red; affinities - sock, houseboat" do
      :rand.seed(:exsss, {1, 8, 12})
      room = Room.reserve("hello") |> Room.start(4)

      assert room.name == "hello"
      assert room.affinities == [:houseboat, :skub]
      assert room.communities == [:red, :yellow, :blue]
      assert room.chaos == 0
      assert room.chaos_counter == 10
    end
  end

  describe "changes" do
    setup do
      room = %Room{chaos: 4}
      %{room: room}
    end

    test "change chaos countdown", %{room: room} do
      new_room = Change.apply_change(room, ChangeDescriptions.change_chaos(5))
      assert new_room.chaos == 9
    end

    test "pass invalid offset in change description", %{room: room} do
      assert_raise ArithmeticError, fn ->
        Change.apply_change(room, ChangeDescriptions.change_chaos("hi"))
      end
    end

    test "pass opts without required fields", %{room: room} do
      assert_raise ArgumentError, fn ->
        Change.apply_change(room, invalid: "random")
      end
    end
  end
end
