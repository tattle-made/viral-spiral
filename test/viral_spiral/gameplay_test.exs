defmodule ViralSpiral.GameTest do
  alias ViralSpiral.Game
  use ExUnit.Case

  describe "card actions" do
    setup do
      game_state = Fixtures.initialized_game()
      %{state: game_state}
    end

    test "passing an affinity card changes the player's clout and affinity", %{state: game_state} do
    end
  end
end
