defmodule ViralSpiralWeb.MultiplayerRoom.StateAdapter do
  alias ViralSpiral.S3
  alias ViralSpiral.Canon
  alias ViralSpiral.Affinity
  alias Phoenix.HTML.FormData
  alias ViralSpiral.Canon.Card.Sparse
  alias ViralSpiral.Entity.DynamicCard
  alias ViralSpiral.Entity.Turn
  alias ViralSpiral.Entity.Player.Map, as: PlayerMap
  alias ViralSpiral.Room.State
  alias ViralSpiral.Room.StateTransformation
  alias ViralSpiral.Room.Template

  def make_game_room(%State{} = state, player_name) do
    player_me = PlayerMap.me(state.players, player_name)
    other_players = PlayerMap.other_than_me(state.players, player_name)
    player_me_id = player_me.id

    %{
      room: %{
        id: state.room.id,
        name: state.room.name,
        chaos: state.room.chaos_counter - state.room.chaos,
        bg_image: S3.bg("bg_#{floor(state.room.chaos / state.room.chaos_counter * 4)}.png"),
        state: state.room.state
      },
      end_game_message: generate_end_game_message(state),
      me: make_me(state, player_me),
      can_use_power: !state.turn.power,
      power_cancel: make_cancel(state, player_me_id),
      power_turn_fake: make_power_turn_fake(state, player_me_id),
      power_viral_spiral: make_power_viral_spiral(state, player_me_id),
      current_cards: make_current_cards(state, player_me),
      hand:
        player_me.hand
        |> Enum.map(&Canon.get_card_from_store(&1))
        |> Enum.map(fn card ->
          %{
            id: card.id,
            image: card.image,
            headline: maybe_patch_headline(card, state.dynamic_card),
            veracity: card.veracity
          }
        end),
      others: make_others(state, other_players),
      current_holder_name: make_current_holder_text(state),
      current_turn_player: make_turn_player(state)
    }
  end

  def make_turn_player(%State{} = state) do
    round = state.round
    # Order of players (list)
    order = round.order
    current_player_index = round.current
    current_turn_player_id = Enum.at(order, current_player_index)
    current_turn_player = state.players[current_turn_player_id]
    %{id: current_turn_player_id, name: current_turn_player.name}
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
        can_turn_fake: StateTransformation.can_turn_fake(state, Sparse.new(&1.id, &1.veracity))
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
    fake_headline = card.fake_headline
    sparse_card = Sparse.new(card.id, card.veracity)

    case dynamic_card.identity_stats[sparse_card] do
      nil -> headline
      stats -> DynamicCard.patch(fake_headline, stats)
    end
  end

  def make_cancel(state, current_player_id) do
    cancel_threshold = state.room.cancel_threshold

    player = state.players[current_player_id]
    affinities = player.affinities

    crosses_cancel_threshold =
      Map.values(affinities)
      |> Enum.filter(&(abs(&1) >= cancel_threshold))
      |> length() > 0

    is_current_player = State.current_turn_player(state).id == current_player_id

    can_cancel = crosses_cancel_threshold && is_current_player

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

    from_player_id = get_in(state.power_cancel_player.from)
    target_player_id = get_in(state.power_cancel_player.target)

    from_player =
      !is_nil(from_player_id) && %{id: from_player_id, name: state.players[from_player_id].name}

    target_player =
      !is_nil(target_player_id) &&
        %{id: target_player_id, name: state.players[target_player_id].name}

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
            value: nil
          },
          targets: %{
            options: target_options,
            value: nil
          }
        }
      },
      can_vote: can_vote,
      from_player: from_player,
      target_player: target_player
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

  def make_power_turn_fake(state, player_id) do
    threshold = state.room.turn_fake_threshold
    player = state.players[player_id]

    enabled =
      Map.values(player.biases)
      |> Enum.filter(&(abs(&1) >= threshold))
      |> length() > 0

    %{
      enabled: enabled
    }
  end

  def make_power_viral_spiral(state, player_id) do
    threshold = state.room.viral_spiral_threshold
    player = state.players[player_id]

    # Enable if (a) any bias >= threshold OR (b) any affinity has |value| >= 5,
    # and it's the current player's turn.
    bias_enabled =
      player.biases
      |> Map.values()
      |> Enum.any?(&(&1 >= threshold))

    affinity_enabled =
      player.affinities
      |> Map.values()
      |> Enum.any?(&(abs(&1) >= threshold))

    enabled =
      (bias_enabled or affinity_enabled) && State.current_turn_player(state).id == player_id

    %{enabled: enabled}
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
      player -> "🎴 #{player.name} is holding the card."
    end
  end
end
