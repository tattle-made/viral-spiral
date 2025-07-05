defmodule ViralSpiral.Entity.Turn do
  @moduledoc """
  Orchestrates whose turn it is in the game.

  It answers whose turn it is and what actions are they allowed to take.
  This also evaluates who are they allowed to pass the card to.

  todo : could the field be actions and not tied to every concrete thing like pass, discard etc.

  ## Turn fields
    * `path` - helps keep track a card's history
    * `power` - helps enforce a one-power-per-turn constraint
  """
  alias ViralSpiral.Entity.Turn.Exception.IllegalPass
  alias ViralSpiral.Canon.Card.Sparse
  alias ViralSpiral.Entity.Change
  alias ViralSpiral.Entity.Turn
  alias ViralSpiral.Entity.Round

  defstruct card: nil,
            current: nil,
            pass_to: [],
            # track the order in which this card has been passed around
            path: [],
            power: false

  @type t :: %__MODULE__{
          card: Sparse.t(),
          current: String.t() | nil,
          pass_to: list(String.t()),
          path: list(String.t()),
          power: boolean()
        }

  @spec new() :: Turn.t()
  def new() do
    %Turn{}
  end

  @spec new(Round.t()) :: Turn.t()
  def new(%Round{} = round) do
    current = Enum.at(round.order, round.current)

    %Turn{
      current: current,
      pass_to: Enum.filter(round.order, &(&1 != current))
    }
  end

  def new(%Round{} = _round, %Turn{} = _turn) do
  end

  def skeleton() do
    %Turn{}
  end

  def set_current(%Turn{} = turn, current), do: %{turn | current: current}

  def set_pass_to(%Turn{} = turn, pass_to), do: %{turn | pass_to: pass_to}

  def set_path(%Turn{} = turn, path), do: %{turn | path: path}

  @doc """
  todo :  add check to ensure that it only runs next if
  to is in the the current pass_to
  """
  @spec next(Turn.t(), String.t()) :: Turn.t()
  def next(%Turn{} = from, to) when is_bitstring(to) do
    can_pass = to in from.pass_to

    if can_pass do
      from
      |> set_current(to)
      |> set_pass_to(List.delete(from.pass_to, to))
      |> set_path(List.insert_at(from.path, -1, from.current))
    else
      raise IllegalPass
    end
  end

  @spec next(Turn.t(), list(String.t())) :: list(Turn.t())
  def next(%Turn{} = from, to) when is_list(to) do
    new_pass_to = from.pass_to -- to

    Enum.map(
      to,
      &%Turn{current: &1, pass_to: new_pass_to}
    )
  end

  defimpl Change do
    alias ViralSpiral.Entity.Turn.Change.SetPowerTrue
    alias ViralSpiral.Entity.Turn.Change.{NewTurn, NextTurn}

    @type changes :: NewTurn.t() | NextTurn.t()

    @spec change(Turn.t(), changes()) :: Turn.t()
    def change(%Turn{} = _turn, %NewTurn{} = change) do
      Turn.new(change.round)
    end

    def change(%Turn{} = turn, %NextTurn{} = change) do
      Turn.next(turn, change.target)
    end

    def change(%Turn{} = turn, %SetPowerTrue{} = _change) do
      %{turn | power: true}
    end
  end
end
