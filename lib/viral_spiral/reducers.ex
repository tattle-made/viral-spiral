defmodule ViralSpiral.Reducers do
  alias ViralSpiral.Room.State.Player
  alias ViralSpiral.Canon.Deck
  alias ViralSpiral.Canon.Deck.DrawTypeRequirements
  alias ViralSpiral.Room.State.Root

  # [
  #   {state.turn, [type: :next, target: to]},
  #   {state.players[from], [type: :clout, offset: 1]},
  #   {state.players[from], [type: :bias, target: card.target, offset: 1]}
  # ] ++
  #   (Map.keys(state.players)
  #    |> Enum.filter(&(state.players[&1].identity == card.target))
  #    |> Enum.map(&{state.players[&1], [type: :clout, offset: -1]}))

  def draw_card(%Root{} = state) do
    requirements = %DrawTypeRequirements{
      tgb: 4,
      total_tgb: 10,
      biases: [:red, :yellow, :blue],
      affinities: [:skub, :highfive],
      current_player: %{
        identity: :blue
      }
    }

    sets = state.deck.available_cards

    type = Deck.draw_type(requirements) |> IO.inspect()
    card = Deck.draw_card(sets, type)
    new_sets = Deck.remove_card(sets, type, card)

    deck = state.deck
    new_deck = %{deck | available_cards: new_sets}

    current_player = state.players[state.turn.current]
    new_current_player = Player.add_active_card(current_player, card.id)
    new_players = Map.put(state.players, new_current_player.id, new_current_player)

    %{state | deck: new_deck, players: new_players}
  end

  def pass_card(card, from, to) do
  end

  def keep_card(card, from) do
  end

  def discard_card(card, from) do
  end

  def check_source(card) do
  end

  def turn_to_fake(card) do
  end

  def cancel_player(player, from) do
  end

  def viral_spiral(players, from) do
  end
end
