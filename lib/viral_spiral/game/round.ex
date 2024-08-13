defmodule ViralSpiral.Game.Round do
  @moduledoc """
  Orchestrates the sequence in which players draw cards.

  There are two things to orchestrate. Round  Who will make the next move and who will draw the next card. The former is called

  Each player gets a chance to draw a card. If 4 players A, B, C, D are playing the game. Round Order determines the order in which players will draw a card. This order is setup at the beginning of the game and does not change.
  A possible Round could be B ->  A -> D -> C, which then repeats throughout the game.

  Within a Round, a player could pass the card to any player without respecting the Round order. At which point the card's journey is managed using `Turn`

  ## Create a new Round for a game
  round = Round.new(players)
  draw_order = Round.order(round)
    ordered array denoting the order of drawing cards.
  Round.start(round)
  Round.current(round)
  Round.next(round)

  ## Fields
  - `order` - Player IDs in the order in which they draw a card.


  # Doubt
  should it use game to initialize or players?
  """

  # alias ViralSpiral.Game.Player

  defstruct order: [],
            count: 0,
            current: 0,
            skip: nil

  @doc """
  todo : this doesn't really need the players, merely a count of players, maybe?
  """
  def new(player_list) do
    order =
      Enum.shuffle(player_list)
      |> Enum.map(& &1.id)

    %__MODULE__{
      count: length(player_list),
      order: order,
      current: 0
    }
  end

  @doc """
  Skips a Player's `Turn`.

  If the player has already had their turn in this round, they are marked to be skipped in the next round.
  If the player has not had their turn in this round yet, they will be marked to be skipped in this round.

  skip = %{
    player: "player_asdf",
    round: :next || :current
  }
  """
  def add_skip(%__MODULE__{} = round, player_id) when is_bitstring(player_id) do
    skip =
      case Enum.find(round.order, &(&1 == player_id)) do
        x ->
          case x < round.order do
            true -> %{player: player_id, round: :next}
            false -> %{player: player_id, round: :current}
          end
      end

    %__MODULE__{round | skip: skip}
  end

  def add_skip(%__MODULE__{} = round, nil) do
    %__MODULE__{round | skip: nil}
  end

  @doc """
  todo :  add logic if skipping is enabled
  """
  def next(%__MODULE__{skip: nil} = round) do
    ix = rem(round.current + 1, round.count)
    %__MODULE__{round | current: ix}
  end

  def next(%__MODULE__{skip: %{round: :next, player: player} = skip} = round) do
    ix = rem(round.current + 1, round.count)
    skip = if ix == 0, do: %{skip: %{round: :current, player: player}}, else: skip
    %__MODULE__{round | skip: skip, current: ix}
  end

  def next(%__MODULE__{skip: %{round: :current, player: player}} = round) do
    ix = rem(round.current + 1, round.count)

    changes =
      if Enum.at(round.order, ix) == player do
        %{skip: nil, current: rem(ix + 1, round.count)}
      else
        %{current: ix}
      end

    Map.merge(round, changes)
  end

  def current_id() do
  end
end
