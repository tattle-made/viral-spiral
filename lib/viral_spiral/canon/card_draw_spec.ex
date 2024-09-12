defmodule ViralSpiral.Canon.CardDrawSpec do
  @moduledoc """
  Specify requirements for the kind of card to draw.

  This struct is passed to `ViralSpiral.Canon.Deck.draw_type()`

  A common way to create a struct is by passing a current room's config

  # Example struct
  requirements = %{
    tgb: 4,
    total_tgb: 10,
    biases: [:red, :blue],
    affinities: [:cat, :sock],
    current_player: %{
      identity: :blue
    }
  }
  """
  alias ViralSpiral.Room.State.Player
  alias ViralSpiral.Game.State.Root
  alias ViralSpiral.Affinity
  alias ViralSpiral.Bias
  alias ViralSpiral.Canon.CardDrawSpec

  defstruct tgb: 0,
            total_tgb: Application.compile_env(:viral_spiral, EngineConfig)[:chaos_counter],
            biases: [],
            affinities: [],
            current_player: nil

  @type t :: %__MODULE__{
          tgb: integer(),
          total_tgb: integer(),
          biases: list(Bias.target()),
          affinities: list(Affinity.target()),
          current_player: %{
            identity: Bias.target()
          }
        }

  @spec set_biases(CardDrawSpec.t(), list(Bias.target())) :: CardDrawSpec.t()
  def set_biases(%CardDrawSpec{} = spec, biases) do
    %{spec | biases: biases}
  end

  @spec set_affinities(CardDrawSpec.t(), list(Affinity.target())) :: CardDrawSpec.t()
  def set_affinities(%CardDrawSpec{} = spec, affinities) do
    %{spec | affinities: affinities}
  end

  @spec set_current_player(CardDrawSpec.t(), Player.t()) :: CardDrawSpec.t()
  def set_current_player(%CardDrawSpec{} = spec, %Player{} = player) do
    %{spec | current_player: adapt_player(player)}
  end

  defp adapt_player(%Player{} = player) do
    %{identity: Player.identity(player)}
  end

  defp new(%Root{} = state) do
    %CardDrawSpec{
      tgb: state.room.chaos_countdown,
      # todo
      biases: state.room_config.biases,
      # todo
      affinities: state.room_config.affinities
      # todo
      # current_player: player_store[state.turn.current]
    }
  end
end
