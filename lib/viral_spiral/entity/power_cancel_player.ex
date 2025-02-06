defmodule ViralSpiral.Entity.PowerCancelPlayer do
  @moduledoc """
  The Cancel Super Power.

  When a Player meets certain criteria, they are allowed to cancel another Player. This takes the following form :
  A player initiates cancellation by choosing which player they want to cancel and which of their affinity they want to use for it. The affinity they choose determines who can vote to cancel this player. If the majority votes to cancel the targetted Player, that player will skip a turn.
  """
  alias ViralSpiral.Entity.Change
  alias ViralSpiral.Entity.PowerCancelPlayer
  alias ViralSpiral.Affinity
  import ViralSpiral.Room.EngineConfig.Guards

  defstruct state: :idle,
            from: nil,
            target: nil,
            affinity: nil,
            allowed_voters: [],
            votes: [],
            result: nil

  @type states :: :idle | :waiting | :done

  @typedoc "A player's vote for/against the target"
  @type vote :: %{id: String.t(), vote: boolean()}

  @type t :: %__MODULE__{
          state: states(),
          from: String.t(),
          target: String.t(),
          affinity: Affinity.t(),
          allowed_voters: list(String.t()),
          votes: list(vote()),
          result: boolean()
        }

  @spec start_vote(t(), String.t(), String.t(), Affinity.target()) :: t()
  def start_vote(%PowerCancelPlayer{} = power, from, target, affinity)
      when is_affinity(affinity) do
    %{power | from: from, target: target, affinity: affinity, state: :waiting}
  end

  @spec vote(t(), String.t(), boolean()) :: t()
  def vote(%PowerCancelPlayer{} = power, player, vote, opts \\ []) do
    done = Keyword.get(opts, :done, false)
    state = if done, do: :done, else: power.state
    %{power | votes: power.votes ++ [%{id: player, vote: vote}], state: state}
  end

  def allowed_voters(%PowerCancelPlayer{} = power, players) when is_list(players) do
    %{power | allowed_voters: players}
  end

  @spec put_result(t()) :: t()
  def put_result(%PowerCancelPlayer{} = power) do
    total_votes = length(power.votes)
    true_votes = power.votes |> Enum.filter(& &1.vote) |> length()
    result = if true_votes / total_votes > 0.5, do: true, else: false
    %{power | result: result, state: :done}
  end

  @spec reset(t()) :: t()
  def reset(%PowerCancelPlayer{} = _power) do
    %PowerCancelPlayer{}
  end

  defimpl Change do
    def apply_change(state, change_desc) do
      case change_desc[:type] do
        :initiate -> state
        :add_vote -> state
      end
    end
  end
end
