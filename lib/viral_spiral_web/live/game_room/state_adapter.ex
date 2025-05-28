defmodule ViralSpiralWeb.GameRoom.StateAdapter do
  require IEx

  alias ViralSpiral.Entity.DynamicCard
  alias ViralSpiral.Entity.Turn
  alias ViralSpiral.Canon.Card.Sparse
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
              |> Enum.map(fn card ->
                %{
                  id: card.id,
                  type: card.type,
                  veracity: card.veracity,
                  headline: maybe_patch_headline(card, state.dynamic_card),
                  image: card.image,
                  article_id: card.article_id,
                  pass_to:
                    state.turn.pass_to
                    |> Enum.map(fn id -> %{id: id, name: state.players[id].name} end),
                  source: make_source(state.players[player.id], card),
                  can_mark_as_fake: can_mark_as_fake?(state.turn),
                  can_turn_fake: card.veracity == true
                }
              end)
          }
        )
    }
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
