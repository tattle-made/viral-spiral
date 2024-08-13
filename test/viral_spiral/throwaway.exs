defmodule ViralSpiral.Throwaway do
  alias ViralSpiral.Game

  describe "draw cards" do
    test "draw unused card" do
      game = Game.new()

      assert game.id != nil
      assert game.deck.status == :loading
      # wait for deck to load

      # game = game |> Game.add_player()
    end
  end
end
