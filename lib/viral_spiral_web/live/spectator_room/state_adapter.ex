defmodule ViralSpiralWeb.SpectatorRoom.StateAdapter do
  @moduledoc """
  Builds a read-only UI map for the Spectator room.

  Key differences from multiplayer:
  - No mutation: spectators never `GenServer.call/2` to change room state.
  - No per-view side effects: actions are ignored; UI is derived from the
    current GenServer state only.
  - Source fallback: when creating `card.source`, we first look up the owning
    player's `open_articles`. If absent (typical for spectators), we fall back
    to `ViralSpiral.Canon.get_article_from_store/1` so spectators can still read
    the source article without mutating game state.
  """
  alias ViralSpiral.Canon
  alias ViralSpiral.Affinity
  alias Phoenix.HTML.FormData
  alias ViralSpiral.Canon.Card.Sparse
  alias ViralSpiral.Entity.DynamicCard
  alias ViralSpiral.Entity.Turn
  alias ViralSpiral.Entity.Player.Map, as: PlayerMap
  alias ViralSpiral.Room.State
  alias ViralSpiral.Room.Template

  def make_spectator_room(%State{} = state) do
    %{
      room: %{
        id: state.room.id,
        name: state.room.name,
        chaos: state.room.chaos,
        state: state.room.state
      },
      end_game_message: generate_end_game_message(state),
      all_players: make_all_players_with_cards(state),
      current_holder_name: make_current_holder_text(state),
      current_turn_player: make_current_turn_player(state),
      current_cards: make_current_cards(state, state.turn.current)
    }
  end

    def make_current_cards(%State{} = state, player) do
      IO.inspect(state, label: "PLAYER: ")

      player = state.players[player]

    player.active_cards
    |> Enum.map(&Canon.get_card_from_store(&1))
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

  defp make_all_players_with_cards(%State{} = state) do
    state.players
    |> Map.values()
    |> Enum.map(fn player ->
      %{
        id: player.id,
        name: player.name,
        identity: player.identity,
        clout: player.clout,
        biases: player.biases,
        affinities: player.affinities,
        is_current_turn: state.turn.current == player.id,
        active_cards: make_player_active_cards(state, player),
        hand: make_player_hand(state, player)
      }
    end)
  end

  defp make_player_active_cards(%State{} = state, player) do
    player.active_cards
    |> Enum.map(&Canon.get_card_from_store(&1))
    |> Enum.map(fn card ->
      %{
        id: card.id,
        veracity: card.veracity,
        headline: maybe_patch_headline(card, state.dynamic_card),
        image: card.image,
        type: card.type,
        article_id: card.article_id,
        pass_to:
          state.turn.pass_to
          |> Enum.map(fn id -> %{id: id, name: state.players[id].name} end),
        source: make_source(state.players[player.id], card),
        can_mark_as_fake: can_mark_as_fake?(state.turn),
        can_turn_fake: card.veracity == true
      }
    end)
  end

  defp make_player_hand(%State{} = state, player) do
    player.hand
    |> Enum.map(&Canon.get_card_from_store(&1))
    |> Enum.map(fn card ->
      %{
        id: card.id,
        image: card.image,
        headline: maybe_patch_headline(card, state.dynamic_card),
        veracity: card.veracity
      }
    end)
  end

  defp make_current_turn_player(%State{} = state) do
    case State.current_turn_player(state) do
      nil ->
        nil

      player ->
        %{
          id: player.id,
          name: player.name,
          identity: player.identity
        }
    end
  end

  defp make_source(player, card) do
    sparse_card = Sparse.new(card.id, card.veracity)
    # In spectator mode, the viewing player does not mutate open_articles.
    # Fall back to the global Canon store so spectators can always read the article.
    article = player.open_articles[sparse_card] || Canon.get_article_from_store(sparse_card)

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

  def generate_end_game_message(%State{} = state) do
    case state.room.state do
      :over ->
        case State.game_over_status(state) do
          {:over, :world, data} ->
            Template.generate_game_over_message(data)

          {:over, :player, data} ->
            Template.generate_game_over_message(data)
        end

      _ ->
        nil
    end
  end

  def make_current_holder_text(%State{turn: %{current: current_id}, players: players}) do
    case Map.get(players, current_id) do
      nil -> nil
      player -> "🎴 It's #{player.name}'s turn now."
    end
  end
end
