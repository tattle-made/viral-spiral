defmodule ViralSpiralWeb.GameRoom.StateAdapter do
  alias ViralSpiral.Room.State

  def game_room(%State{} = state) do
    %{id: current_player_id} = State.current_turn_player(state)

    %{
      room: %{
        name: state.room.name,
        chaos: state.room.chaos
      },
      players:
        for(
          {id, player} <- state.players,
          do: %{
            id: player.id,
            name: player.name,
            clout: player.clout,
            affinities: player.affinities,
            biases: player.biases,
            is_active: state.turn.current == player.id,
            cards:
              player.active_cards
              |> Enum.map(&state.deck.store[&1])
              |> Enum.map(
                &%{
                  id: &1.id,
                  type: &1.type,
                  veracity: &1.veracity,
                  headline: &1.headline,
                  image: &1.image,
                  article_id: &1.article_id,
                  pass_to:
                    state.turn.pass_to
                    |> Enum.map(fn id -> %{id: id, name: state.players[id].name} end)
                }
              )
          }
        )
    }
  end
end
