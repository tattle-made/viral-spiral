alias ViralSpiral.Canon.{Deck, Encyclopedia, Article}
alias ViralSpiral.Canon.Card.Sparse
alias ViralSpiral.Canon.Card
alias ViralSpiral.Entity.{Room, Player, Round, Turn}
alias ViralSpiral.Room.State

defmodule Debug do
  alias ViralSpiralWeb.GameRoom.StateAdapter
  alias ViralSpiral.Room

  def state(room_name) do
    {:ok, pid} = Room.room_gen!(room_name)
    state = :sys.get_state(pid)
    ui_state = StateAdapter.game_room(state)

    {state, ui_state}
  end
end
