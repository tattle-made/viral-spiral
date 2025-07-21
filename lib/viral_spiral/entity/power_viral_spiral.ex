defmodule ViralSpiral.Entity.PowerViralSpiral do
  @moduledoc """
  Struct used to conduct special power of viral spiral.

  When a user uses the power of viral spiral, they can pass a card from their hand to multiple players. This is a very special case of the game where a player can hold multiple cards and pass to other players.
  """

  alias ViralSpiral.Canon.Card.Sparse
  alias ViralSpiral.Entity.Change
  alias ViralSpiral.Entity.Player
  alias ViralSpiral.Entity.PowerViralSpiral
  alias ViralSpiral.Entity.Turn
  defstruct [:status, :turns, :from, :to, :card]

  @type t :: %__MODULE__{
          status: :active | :inactive,
          turns: list(Turn.t()),
          from: String.t(),
          to: list(String.t()),
          card: Sparse.t()
        }

  def skeleton() do
    %PowerViralSpiral{status: :inactive}
  end

  def new(from, to, %Sparse{} = card) when is_bitstring(from) and is_list(to) do
    %PowerViralSpiral{
      status: :active,
      from: from,
      to: to,
      card: card
    }
  end

  defimpl Change do
    alias ViralSpiral.Entity.PowerViralSpiral.Changes.InitiateViralSpiral

    def change(_power_viral_spiral, %InitiateViralSpiral{} = change) do
      PowerViralSpiral.new(change.from_id, change.to_id, change.card)
    end
  end
end
