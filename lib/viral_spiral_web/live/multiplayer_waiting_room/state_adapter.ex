defmodule ViralSpiralWeb.MultiplayerWaitingRoom.StateAdapter do
  alias ViralSpiral.Canon
  alias ViralSpiral.Entity.Player.Map, as: PlayerMap
  alias ViralSpiral.Room.State

  def make_game_room(%State{} = state, player_name) do
    %{
      room: %{
        id: state.room.id,
        name: state.room.name,
        players: state.room.unjoined_players
      }
    }

    # player_me = PlayerMap.me(state.players, player_name)
    # other_players = PlayerMap.other_than_me(state.players, player_name)
    # player_me_id = player_me.id

    # %{
    #   room: %{
    #     id: state.room.id,
    #     name: state.room.name,
    #     chaos: state.room.chaos
    #   },
    #   me: make_me(state, player_me),
    #   current_cards: make_current_cards(state, player_me),
    #   others: make_others(state, other_players)
    # }
  end

  defp make_me(%State{} = state, player) do
    %{
      id: player.id,
      name: player.name,
      clout: player.clout,
      biases: player.biases,
      affinities: player.affinities
    }
  end

  def make_current_cards(%State{} = state, player) do
    player.active_cards
    |> Enum.map(&Canon.get_card_from_store(&1))
    |> Enum.map(
      &%{
        id: &1.id,
        veracity: &1.veracity,
        headline: &1.headline,
        image: &1.image
      }
    )
  end

  defp make_others(state, other_players) do
    other_players
    |> Enum.map(fn player ->
      %{
        id: player.id,
        name: player.name,
        clout: player.clout,
        biases: player.biases,
        affinities: player.affinities
      }
    end)
  end
end
