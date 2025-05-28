defmodule StateFixtures do
  alias ViralSpiral.Room.StateTransformation
  alias ViralSpiral.Canon
  alias ViralSpiral.Canon.Deck.CardSet
  alias ViralSpiral.Entity.Turn
  alias ViralSpiral.Entity.Round
  alias ViralSpiral.Entity.Player
  alias ViralSpiral.Canon.Card.Sparse
  alias ViralSpiral.Room.State
  alias ViralSpiral.Entity.Room

  def new_game_with_four_players() do
    room =
      Room.skeleton()
      |> Room.join("adhiraj")
      |> Room.set_state(:reserved)
      |> Room.join("aman")
      |> Room.join("farah")
      |> Room.join("krys")
      |> Room.start()

    state = %State{room: room}
    state = State.setup(state)
    state = %{state | room: room |> Room.reset_unjoined_players()}
    players = StateTransformation.player_id_by_names(state)

    {state, players}
  end
end
