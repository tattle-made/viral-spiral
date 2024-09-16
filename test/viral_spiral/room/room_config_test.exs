defmodule ViralSpiral.Room.RoomConfigTest do
  alias ViralSpiral.Room.RoomConfig
  use ExUnit.Case

  describe "deterministic room configs" do
    test "communities - yellow, red; affinities - sock, houseboat" do
      :rand.seed(:exsss, {1, 8, 12})
      room = RoomConfig.new(3)

      assert room == %RoomConfig{
               affinities: [:houseboat, :skub],
               communities: [:yellow, :red],
               chaos_counter: 10,
               volatality: :medium
             }
    end

    test "communities - a,b; affinities - x,y" do
      :rand.seed(:exsss, {1, 2, 12})
      room = RoomConfig.new(3)

      assert room = %RoomConfig{
               affinities: [:highfive, :skub],
               communities: [:yellow, :blue],
               chaos_counter: 10,
               volatality: :medium
             }
    end
  end
end
