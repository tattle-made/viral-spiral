defmodule ViralSpiral.Entity.PowerViralSpiral do
  @moduledoc """
  Struct used to conduct special power of viral spiral.

  When a user uses the power of viral spiral, they can pass a card from their hand to multiple players. This is a very special case of the game where a player can hold multiple cards and pass to other players.
  """

  alias ViralSpiral.Bias
  alias ViralSpiral.Canon.Card.Sparse
  alias ViralSpiral.Entity.Change
  alias ViralSpiral.Entity.Player
  alias ViralSpiral.Entity.PowerViralSpiral
  alias ViralSpiral.Entity.Turn
  defstruct [:turns, :card, :from, :bias]

  @type t :: %__MODULE__{
          card: Sparse.t(),
          turns: list(Turn.t()),
          from: UXID.uxid_string(),
          bias: Bias.t()
        }

  def new(%Sparse{} = card, players) when is_list(players) do
    Enum.map(
      players,
      &%Turn{
        card: %Sparse{id: card.id, veracity: card.veracity},
        current: &1,
        pass_to: players
      }
    )
  end

  def get_turn(%PowerViralSpiral{} = power, player_id) do
    power.turns
    |> Enum.filter(&(&1.current == player_id))
    |> hd
  end

  @doc """
  Return turns other than the one of the passed player_id
  """
  def other_turns(%PowerViralSpiral{} = power, player_id) do
    Enum.filter(power.turns, &(&1.current != player_id))
  end

  def put_turn(%PowerViralSpiral{} = power, player_id, %Turn{} = turn) do
    ix = Enum.find_index(power.turns, &(&1.current == player_id))

    new_turns = List.replace_at(power.turns, ix, turn)
    %{power | turns: new_turns}
  end

  def pass_to(%PowerViralSpiral{} = power, %Player{id: player_id}) do
    power.turns
    |> Enum.filter(&(&1.current == player_id))
    |> hd
    |> Map.get(:pass_to)
  end

  def pass_to(%PowerViralSpiral{} = power, player_id) when is_bitstring(player_id) do
    power.turns
    |> Enum.filter(&(&1.current == player_id))
    |> hd
    |> Map.get(:pass_to)
  end

  def reset(%PowerViralSpiral{}) do
    nil
  end

  defimpl Change do
    alias ViralSpiral.Entity.PowerViralSpiral.Changes.InitiateViralSpiral

    def change(power, %InitiateViralSpiral{} = change) do
      %PowerViralSpiral{
        card: change.card,
        from: change.from_id,
        bias: change.bias
        # turns: Enum.reduce(change.to, %{}, fn to_id, acc ->
        #   Map.put(acc, to_id, %Turn{current: to_id, pass_to: } )
        # end)
      }
    end

    # def apply_change(state, change_desc) do
    #   case change_desc[:type] do
    #     :set ->
    #       players = change_desc[:players]
    #       card = change_desc[:card]

    #       PowerViralSpiral.new(card, players)

    #     :reset ->
    #       PowerViralSpiral.reset(state)

    #     :pass ->
    #       from = change_desc[:from]
    #       to = change_desc[:to]
    #       turn = PowerViralSpiral.get_turn(state, from)

    #       turn = Change.apply_change(turn, ChangeDescriptions.pass_turn_to(to))

    #       # remove options from other player's turn
    #       other_turns =
    #         PowerViralSpiral.other_turns(state, from)
    #         |> Enum.map(&Map.put(&1, :pass_to, &1.pass_to -- [to]))

    #       new_turn = [turn] ++ other_turns

    #       # check if this no possible pass options remain
    #       case length(turn.pass_to) do
    #         0 -> nil
    #         _ -> %{state | turns: new_turn}
    #       end
    #   end
    # end
  end
end
