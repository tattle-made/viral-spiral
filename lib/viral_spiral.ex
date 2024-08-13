defmodule ViralSpiral do
  @moduledoc """
  Viral Spiral keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.

  Viral Spiral is a multiplayer game about misinformation. A player (customarily known as the game master) can start a game room and invite his/her friends. When the invited players have joined the room, the game master can choose to start the game.
  """
end

# defmodule ViralSpiral.GameRoom do
#   defstruct [:players, :chaos_countdown]
# end

# defmodule ViralSpiral.Game do
#   @moduledoc """
#   Defines a single Viral Spiral Game
#   """
#   alias ViralSpiral.Game
#   alias ViralSpiral.Player
#   defstruct [:id, :deck, :meta, :players]

#   def new() do
#     %__MODULE__{}
#   end

#   # def add_player(%Game{} = game, %Player{} = player) do
#   #   Map.put(game, :players, game.players ++ player)
#   # end
# end

# defmodule ViralSpiral.GameMeta do
#   @moduledoc """
#   Defines Meta information about the Game.

#   This is set during initialization and not used in game logic
#   """

#   defstruct [:affinities, :communities]
# end

# defmodule ViralSpiral.Affinity do
#   defstruct [:name, :count]
# end

# defmodule ViralSpiral.Bias do
#   defstruct [:name, :count]
# end

# defmodule ViralSpiral.Deck do
#   @moduledoc """
#   Defines the Deck for a Game.
#   """

#   defstruct [:dealt_cards, :available_cards]
# end

# defmodule ViralSpiral.Card do
#   defstruct []
# end

# defmodule ViralSpiral.BiasCard do
# end

# defmodule ViralSpiral.AffinityCard do
# end

# defmodule ViralSpiral.Encyclopedia do
#   defstruct [:articles]
# end

# defmodule ViralSpiral.Article do
#   defstruct [:headline, :publisher, :article]
# end

# defmodule ViralSpiral.Rule do
#   alias ViralSpiral.Player
#   alias ViralSpiral.Game

#   defstruct [:active_player, :chaos_countdown]

#   def new() do
#     %__MODULE__{}
#   end

#   def choose(%Game{} = game) do
#     new()
#     # |> assign(:active_player)
#     # |> assign(:chaos_countdown)
#     # |> assign(:dice_throw)
#     # |> apply
#   end

#   def update_scores(%Game{}) do
#   end

#   def update_score(%Player{}) do
#   end
# end

# defmodule ViralSpiral.CardForDealer do
#   @moduledoc """
#   Struct optimized to be used in card dealing logic.

#   The data fields using this struct are created using conventional struct syntax. No validation is done since this is an internal field.
#   """
#   defstruct [:id, :tgb]
# end

# defmodule ViralSpiral.Throw do
#   alias ViralSpiral.CardForDealer

#   def test() do
#     all_cards_store = [
#       %CardForDealer{id: "abcde", tgb: 0},
#       %CardForDealer{id: "otpew", tgb: 0},
#       %CardForDealer{id: "cnapw", tgb: 1},
#       %CardForDealer{id: "pvkqs", tgb: 1},
#       %CardForDealer{id: "ryqmz", tgb: 2},
#       %CardForDealer{id: "ldkqp", tgb: 2}
#     ]

#     all_cards_set = MapSet.new(all_cards_store)

#     dealt_cards =
#       MapSet.new()
#       |> MapSet.put(%CardForDealer{id: "cnapw", tgb: 1})

#     all_available_cards =
#       MapSet.difference(all_cards_set, dealt_cards)

#     all_cards_below_tgb = Enum.filter(all_cards_set, &(&1.tgb < 2))
#     all_cards_set_below_tgb = MapSet.new(all_cards_below_tgb)

#     actual_available_cards = MapSet.difference(all_cards_set_below_tgb, dealt_cards)

#     :ok
#   end
# end
