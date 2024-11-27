defmodule ViralSpiral.Entity.Turn do
  @moduledoc """
  Orchestrates whose turn it is in the game.

  It answers whose turn it is and what actions are they allowed to take.
  This also evaluates who are they allowed to pass the card to.

  todo : could the field be actions and not tied to every concrete thing like pass, discard etc.
  """
  alias ViralSpiral.Canon.Card.Sparse
  alias ViralSpiral.Entity.Change
  alias ViralSpiral.Entity.Turn
  alias ViralSpiral.Entity.Round

  defstruct card: nil,
            current: nil,
            pass_to: []

  @type t :: %__MODULE__{
          card: Sparse.t(),
          current: String.t() | nil,
          pass_to: list(String.t())
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

  def set_current(%Turn{} = turn, current), do: %{turn | current: current}

  def set_pass_to(%Turn{} = turn, pass_to), do: %{turn | pass_to: pass_to}

  @doc """
  todo :  add check to ensure that it only runs next if
  to is in the the current pass_to
  """
  @spec next(Turn.t(), String.t()) :: Turn.t()
  def next(%Turn{} = from, to) when is_bitstring(to) do
    from
    |> set_current(to)
    |> set_pass_to(List.delete(from.pass_to, to))
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
    def apply_change(turn, change_desc) do
      case change_desc[:type] do
        :next -> Turn.next(turn, change_desc[:target])
        :new -> Turn.new(change_desc[:round])
      end
    end
  end
end
