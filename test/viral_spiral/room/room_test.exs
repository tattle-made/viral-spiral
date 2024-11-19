defmodule ViralSpiral.Room.RoomTest do
  alias ViralSpiral.Entity.Change
  alias ViralSpiral.Entity.Room
  use ExUnit.Case

  describe "deterministic room configs" do
    test "communities - yellow, red; affinities - sock, houseboat" do
      :rand.seed(:exsss, {1, 8, 12})
      room = Room.new(3)

      assert room == %Room{
               affinities: [:houseboat, :skub],
               communities: [:yellow, :red],
               chaos_counter: 10,
               volatality: :medium
             }
    end

    test "communities - a,b; affinities - x,y" do
      :rand.seed(:exsss, {1, 2, 12})
      room = Room.new(3)

      assert room = %Room{
               affinities: [:highfive, :skub],
               communities: [:yellow, :blue],
               chaos_counter: 10,
               volatality: :medium
             }
    end
  end

  describe "Room Functions" do
    test "player one creates a room and collects its link" do
      room = Room.name() |> IO.inspect()
    end
  end

  describe "changes" do
    setup do
      room = %Room{chaos_counter: 4}
      %{room: room}
    end

    test "change chaos countdown", %{room: room} do
      new_room = Change.apply_change(room, offset: 5)
      assert new_room.chaos_counter == 9
    end

    test "pass invalid offset in change description", %{room: room} do
      new_room = Change.apply_change(room, offset: "hi")
      assert new_room.chaos_counter == 4
    end

    test "pass opts without required fields", %{room: room} do
      assert_raise ArgumentError, fn ->
        Change.apply_change(room, invalid: "random")
      end
    end
  end
end
