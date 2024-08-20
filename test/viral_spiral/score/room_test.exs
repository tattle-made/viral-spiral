defmodule ViralSpiral.Score.RoomTest do
  alias ViralSpiral.Score.Change
  alias ViralSpiral.Score.Room
  use ExUnit.Case

  setup_all do
    room = %Room{chaos_countdown: 4}
    %{room: room}
  end

  test "change chaos countdown", %{room: room} do
    new_room = Change.apply_change(room, offset: 5)
    assert new_room.chaos_countdown == 9
  end

  describe "invalid changes" do
    setup do
      room = %Room{chaos_countdown: 2}
      %{room: room}
    end

    test "pass invalid offset in change description", %{room: room} do
      new_room = Change.apply_change(room, offset: "hi")
      assert new_room.chaos_countdown == 2
    end

    test "pass opts without required fields", %{room: room} do
      assert_raise ArgumentError, fn ->
        Change.apply_change(room, invalid: "random")
      end
    end
  end
end
