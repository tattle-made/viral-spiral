defmodule ViralSpiral.Room.Factory do
  @moduledoc """
  Create entities for a Game Room
  """

  alias ViralSpiral.Room.Reducer
  alias ViralSpiral.Room.Actions
  alias ViralSpiral.Room.ChangeDescriptions
  alias ViralSpiral.Room.State
  alias ViralSpiral.Room.EngineConfig
  alias ViralSpiral.Canon.Card.Sparse
  alias ViralSpiral.Canon.Article
  alias ViralSpiral.Canon.Encyclopedia
  alias ViralSpiral.Canon.DrawTypeRequirements
  alias ViralSpiral.Canon.Deck, as: CanonDeck
  alias ViralSpiral.Entity.Change
  alias ViralSpiral.Entity.Deck
  alias ViralSpiral.Entity.Player
  alias ViralSpiral.Entity.Room
  alias ViralSpiral.Entity.Article, as: EntityArticle
  alias ViralSpiralWeb.GameRoomState

  def new_room() do
    engine_config = %EngineConfig{}

    %Room{
      id: UXID.generate!(prefix: "room", size: :small),
      name: Room.name(),
      state: :uninitialized,
      chaos_counter: engine_config.chaos_counter,
      volatality: engine_config.volatility
    }
  end

  @doc """
  Create a new player whose properties conform with the Room settings.
  """
  @spec new_player_for_room(Room.t()) :: Player.t()
  def new_player_for_room(%Room{} = room) do
    identity = Enum.shuffle(room.communities) |> Enum.at(0)

    bias_list = Enum.filter(room.communities, &(&1 != identity))
    bias_map = Enum.reduce(bias_list, %{}, fn x, acc -> Map.put(acc, x, 0) end)

    affinity_list = room.affinities
    affinity_map = Enum.reduce(affinity_list, %{}, fn x, acc -> Map.put(acc, x, 0) end)

    %Player{
      id: UXID.generate!(prefix: "player", size: :small),
      identity: identity,
      biases: bias_map,
      affinities: affinity_map,
      clout: 0
    }
  end

  def draw_type(%State{} = state) do
    %DrawTypeRequirements{
      tgb: state.room.chaos,
      total_tgb: state.room.chaos_counter,
      biases: state.room.communities,
      affinities: state.room.affinities,
      current_player: %{
        identity: State.current_round_player(state).identity
      }
    }
  end

  def new_deck(%Room{} = room) do
    cards = CanonDeck.load_cards()
    articles = Encyclopedia.load_articles()
    article_store = Encyclopedia.create_store(articles)

    cards = CanonDeck.link(cards, article_store)

    set_opts = [
      affinities: room.affinities,
      biases: room.communities
    ]

    %Deck{
      available_cards: CanonDeck.create_sets(cards, set_opts),
      dealt_cards: %{},
      store: CanonDeck.create_store(cards),
      article_store: article_store
    }
  end

  def make_gameroom(%State{} = state) do
    %GameRoomState{
      room: %{
        name: state.room.name,
        chaos: state.room.chaos
      },
      players:
        for(
          {_id, player} <- state.players,
          do: %{
            name: player.name,
            clout: player.clout,
            affinities: player.affinities,
            biases: player.biases,
            is_active: state.turn.current == player.id,
            cards:
              player.active_cards
              |> Enum.map(&state.deck.store[{&1, true}])
              |> Enum.map(
                &%{
                  id: &1.id,
                  type: &1.type,
                  veracity: &1.veracity,
                  headline: &1.headline,
                  image: &1.image,
                  article_id: &1.article_id
                }
              )
          }
        )
    }
  end

  def new_game() do
    %State{
      room: Room.new()
    }
  end

  def join(%State{} = state, player_name) do
    room = Change.apply_change(state.room, ChangeDescriptions.Room.join(player_name))
    %{state | room: room}
  end

  def start(%State{} = state) do
    room =
      state.room
      |> Room.start(length(state.room.unjoined_players))
      |> Room.reset_unjoined_players()

    State.new(room, state.room.unjoined_players)
  end

  def draw_card(%State{} = state) do
    requirements = draw_type(state)
    draw_type = CanonDeck.draw_type(requirements)
    Reducer.reduce(state, Actions.draw_card(draw_type))
  end

  @doc """
  draw_type is a tuple.

  For more, visit `ViralSpiral.Canon.Deck.draw_type/1`
  """
  def draw_card(%State{} = state, draw_type) do
    Reducer.reduce(state, Actions.draw_card(draw_type))
  end

  def pass_card(%State{} = state, %Sparse{} = card, from, to) do
    Reducer.reduce(state, Actions.pass_card(card.id, card.veracity, from, to))
  end

  def keep_card(%State{} = state, %Sparse{} = card, from) do
    Reducer.reduce(state, Actions.keep_card(card, from))
  end

  def discard_card(%State{} = state, %Sparse{} = card, from) do
  end

  def view_source(%State{} = state, player_id, card_id, card_veracity) do
    Reducer.reduce(state, Actions.view_source(player_id, card_id, card_veracity))
  end

  def close_source(%State{} = state, player_id, card_id, card_veracity) do
    Reducer.reduce(state, Actions.hide_source(player_id, card_id, card_veracity))
  end
end
