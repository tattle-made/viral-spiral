defmodule ViralSpiral.StateTest do
  alias ViralSpiral.Room.Factory
  alias ViralSpiral.Room.State
  use ExUnit.Case

  describe "draw card" do
    test "a" do
      # state = %State{}

      state = state |> Factory.draw_card(type: :affinity)
      assert get_in(state.players["player_asdfadf"].clout) == 2
    end
  end

  describe "room" do
    test "reserve room" do
    end

    test "join room" do
    end

    test "close room" do
    end
  end

  describe "deck" do
    setup do
    end

    test "draw cards" do
    end

    test "remove card" do
    end
  end

  describe "pass card" do
    setup do
    end

    test "pass affinity card" do
    end

    test "pass bias card" do
    end

    test "pass topical card" do
    end
  end

  describe "keep card" do
    setup do
    end

    test "keep bias card" do
    end

    test "keep affinity card" do
    end

    test "keep topical card" do
    end
  end

  describe "discard card" do
    setup do
    end

    test "discard bias card" do
    end

    test "discard affinity card " do
    end

    test "discard topical card" do
    end
  end

  describe "check source" do
    setup do
    end

    test "check" do
    end
  end

  describe "mark as fake" do
    setup do
    end
  end

  describe "turn to fake" do
    setup do
    end
  end

  describe "cancel power" do
  end

  describe "viral spiral power" do
  end
end
