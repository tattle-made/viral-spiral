defmodule ViralSpiralWeb.GameRoom.StateAdapter do
  require IEx

  alias ViralSpiral.Bias
  alias ViralSpiral.Entity.Player.Map, as: PlayerMap
  alias ViralSpiral.Affinity
  alias Phoenix.HTML.FormData
  alias Phoenix.HTML.Form
  alias ViralSpiral.Entity.DynamicCard
  alias ViralSpiral.Entity.Turn
  alias ViralSpiral.Canon.Card.Sparse
  alias ViralSpiral.Room.State

  def game_room(%State{} = state) do
    %{id: current_player_id} = State.current_turn_player(state)

    %{
      room: %{
        name: state.room.name,
        chaos_counter: state.room.chaos_counter - state.room.chaos
      },
      players:
        for(
          {id, player} <- state.players,
          do: %{
            id: player.id,
            identity: Bias.label(player.identity),
            name: player.name,
            clout: player.clout,
            affinities: player.affinities,
            biases: player.biases,
            is_active: state.turn.current == player.id,
            power_cancel: make_cancel(state, player.id),
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
              end),
            hand:
              player.hand
              |> Enum.map(&state.deck.store[&1])
              |> Enum.map(fn card ->
                %{
                  id: card.id,
                  image: card.image,
                  headline: maybe_patch_headline(card, state.dynamic_card)
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

  def make_cancel(state, current_player_id) do
    cancel_threshold = state.room.cancel_threshold

    player = state.players[current_player_id]
    affinities = player.affinities

    can_cancel =
      Map.values(affinities)
      |> Enum.filter(&(abs(&1) >= cancel_threshold))
      |> length() > 0

    options = make_options(affinities, cancel_threshold)

    affinity_options =
      options
      |> Enum.reduce([], &Keyword.put(&2, String.to_atom(Affinity.label(&1.type)), &1.type))

    target_options =
      PlayerMap.others(state.players, current_player_id)
      |> Enum.into([])
      |> Enum.map(&elem(&1, 1))
      |> Enum.map(&{&1.id, &1.name})
      |> Enum.reduce([], &Keyword.put(&2, String.to_atom(elem(&1, 1)), elem(&1, 0)))

    can_vote_cond =
      get_in(state.power_cancel_player.state) == :waiting &&
        current_player_id in get_in(state.power_cancel_player.allowed_voters) &&
        Enum.find(state.power_cancel_player.votes, &(&1.id == current_player_id)) == nil

    can_vote =
      case can_vote_cond do
        false ->
          nil

        true ->
          target_id = get_in(state.power_cancel_player.target)
          target_player = state.players[target_id]
          %{id: target_id, name: target_player.name}
      end

    %{
      can_cancel: can_cancel,
      options: options,
      form: %{
        data:
          FormData.to_form(
            %{
              "target_id" => nil,
              "affinity" => nil
            },
            id: "cancel_form"
          ),
        values: %{
          affinity: %{
            options: affinity_options,
            value: ""
          },
          targets: %{
            options: target_options,
            value: ""
          }
        }
      },
      can_vote: can_vote
    }
  end

  def make_options(affinities, cancel_threshold) do
    Enum.map(affinities, fn {k, v} ->
      polarity = if v > 0, do: :positive, else: :negative

      %{
        type: k,
        polarity: polarity,
        can_cancel: abs(v) >= cancel_threshold
      }
    end)
    |> Enum.filter(& &1.can_cancel)
    |> Enum.map(&Map.delete(&1, :can_cancel))
  end
end
