defmodule ViralSpiralWeb.MultiplayerRoom.StateAdapter do
  alias ViralSpiral.Canon.Card.Sparse
  alias ViralSpiral.Entity.DynamicCard
  alias ViralSpiral.Entity.Turn
  alias ViralSpiral.Entity.Player.Map, as: PlayerMap
  alias ViralSpiral.Room.State

  def make_game_room(%State{} = state, player_name) do
    player_me = PlayerMap.me(state.players, player_name)
    other_players = PlayerMap.other_than_me(state.players, player_name)
    player_me_id = player_me.id

    %{
      room: %{
        id: state.room.id,
        name: state.room.name,
        chaos: state.room.chaos
      },
      me: make_me(state, player_me),
      current_cards: make_current_cards(state, player_me),
      others: make_others(state, other_players)
    }
  end

  defp make_me(%State{} = state, player) do
    %{
      id: player.id,
      name: player.name,
      identity: player.identity,
      clout: player.clout,
      biases: player.biases,
      affinities: player.affinities
    }
  end

  def make_current_cards(%State{} = state, player) do
    player.active_cards
    |> Enum.map(&state.deck.store[&1])
    |> Enum.map(
      &%{
        id: &1.id,
        veracity: &1.veracity,
        headline: maybe_patch_headline(&1, state.dynamic_card),
        image: &1.image,
        type: &1.type,
        article_id: &1.article_id,
        pass_to:
          state.turn.pass_to
          |> Enum.map(fn id -> %{id: id, name: state.players[id].name} end),
        source: make_source(state.players[player.id], &1),
        can_mark_as_fake: can_mark_as_fake?(state.turn),
        can_turn_fake: &1.veracity == true
      }
    )
  end

  defp make_others(state, other_players) do
    other_players
    |> Enum.map(fn player ->
      %{
        id: player.id,
        name: player.name,
        identity: player.identity,
        clout: player.clout,
        biases: player.biases,
        affinities: player.affinities
      }
    end)
  end

  defp make_source(player, card) do
    sparse_card = Sparse.new(card.id, card.veracity)
    article = player.open_articles[sparse_card]

    case article do
      nil ->
        nil

      article ->
        %{
          type: article.type,
          headline: article.headline,
          content: article.content,
          author: article.author
        }
    end
  end

  defp can_mark_as_fake?(%Turn{} = turn) do
    length(turn.path) > 0
  end

  def maybe_patch_headline(card, %DynamicCard{} = dynamic_card) do
    alias ViralSpiral.Canon.DynamicCard

    headline = card.headline
    sparse_card = Sparse.new(card.id, card.veracity)

    case dynamic_card.identity_stats[sparse_card] do
      nil -> headline
      stats -> DynamicCard.patch(headline, stats)
    end
  end
end
