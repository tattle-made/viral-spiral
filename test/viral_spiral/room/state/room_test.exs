defmodule ViralSpiral.Room.State.RoomTest do
  alias ViralSpiral.Room.State.Change
  alias ViralSpiral.Room.State.Room
  use ExUnit.Case

  describe "changes" do
    setup do
      room = %Room{chaos_countdown: 4}
      %{room: room}
    end

    test "change chaos countdown", %{room: room} do
      new_room = Change.apply_change(room, nil, offset: 5)
      assert new_room.chaos_countdown == 9
    end

    test "pass invalid offset in change description", %{room: room} do
      new_room = Change.apply_change(room, nil, offset: "hi")
      assert new_room.chaos_countdown == 4
    end

    test "pass opts without required fields", %{room: room} do
      assert_raise ArgumentError, fn ->
        Change.apply_change(room, invalid: "random")
      end
    end
  end
end
