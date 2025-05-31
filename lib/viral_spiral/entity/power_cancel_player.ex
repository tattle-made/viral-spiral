defmodule ViralSpiral.Entity.PowerCancelPlayer do
  @moduledoc """
  The Cancel Super Power.

  When a Player meets certain criteria, they are allowed to cancel another Player. This takes the following form :
  A player initiates cancellation by choosing which player they want to cancel and which of their affinity they want to use for it. The affinity they choose determines who can vote to cancel this player. If the majority votes to cancel the targetted Player, that player will skip a turn.
  """
  require IEx
  alias ViralSpiral.Entity.PowerCancelPlayer.Exceptions.VoteAlreadyRegistered
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

  def skekelton() do
    %PowerCancelPlayer{}
  end

  @spec start_vote(t(), String.t(), String.t(), Affinity.target()) :: t()
  def start_vote(%PowerCancelPlayer{} = power, from, target, affinity)
      when is_affinity(affinity) do
    %{power | from: from, target: target, affinity: affinity, state: :waiting}
  end

  @spec vote(t(), String.t(), boolean()) :: t()
  def vote(%PowerCancelPlayer{} = power, player, vote, opts \\ []) do
    done = Keyword.get(opts, :done, false)
    state = if done, do: :done, else: power.state

    vote_by_player = Enum.find(power.votes, fn vote -> vote.id == player end)

    case vote_by_player do
      nil -> %{power | votes: power.votes ++ [%{id: player, vote: vote}], state: state}
      _ -> raise VoteAlreadyRegistered
    end
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

  defimpl Change do
    alias ViralSpiral.Entity.PowerCancelPlayer.Changes.ResetCancel
    alias ViralSpiral.Entity.PowerCancelPlayer.Changes.VoteCancel
    alias ViralSpiral.Entity.PowerCancelPlayer.Changes.InitiateCancel

    def change(power_cancel_player, %InitiateCancel{} = change) do
      power_cancel_player
      |> PowerCancelPlayer.start_vote(change.from_id, change.to_id, change.affinity)
      |> PowerCancelPlayer.allowed_voters(change.allowed_voters)
    end

    def change(power_cancel_player, %VoteCancel{} = change) do
      power_cancel_player
      |> PowerCancelPlayer.vote(change.from_id, change.vote)
      |> then(fn power ->
        case length(power.votes) == length(power.allowed_voters) do
          true -> PowerCancelPlayer.put_result(power)
          false -> power
        end
      end)

      # todo make this then block a maybe_* function
    end

    def change(_power_cancel_player, %ResetCancel{} = _change) do
      PowerCancelPlayer.skekelton()
    end
  end
end
