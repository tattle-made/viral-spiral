defmodule ViralSpiral.RuleTest do
  use ExUnit.Case

  describe "card passing rules" do
    test "you can only pass card to people after you in the turn order" do
      _game = Fixtures.initialized_game()
    end
  end
end
