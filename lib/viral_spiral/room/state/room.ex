defmodule ViralSpiral.Room.State.Room do
  @moduledoc """
  ## Example

  """
  alias ViralSpiral.Room.State.Room

  defstruct chaos_countdown: 10,
            id: "",
            name: "",
            state: :uninitialized

  @all_states [:uninitialized, :waiting_for_players, :running, :paused]

  @type states :: :uninitialized | :waiting_for_players | :running | :paused
  @type t :: %__MODULE__{
          chaos_countdown: integer(),
          id: String.t(),
          name: String.t(),
          state: states()
        }

  @doc """
  Create a new Room with default values.
  """
  @spec new() :: t()
  def new() do
    %Room{
      id: UXID.generate!(prefix: "room", size: :small),
      state: :uninitialized
    }
  end

  def set_state(%Room{} = room, state) when state in @all_states do
    %{room | state: state}
  end

  @doc """
  Reduce the chaos countdown by 1.
  """
  @spec countdown(t()) :: t()
  def countdown(%Room{} = room) do
    %{room | chaos_countdown: room.chaos_countdown - 1}
  end
end

defimpl ViralSpiral.Room.State.Change, for: ViralSpiral.Room.State.Room do
  alias ViralSpiral.Game.State
  alias ViralSpiral.Room.State.Room

  @doc """
  Change state of a Room.
  """
  @spec apply_change(Room.t(), State.t(), keyword()) :: Room.t()
  def apply_change(%Room{} = score, _global_state, opts) do
    opts = Keyword.validate!(opts, offset: 0)

    case opts[:offset] do
      x when is_integer(x) ->
        Map.put(score, :chaos_countdown, score.chaos_countdown + opts[:offset])

      y when is_bitstring(y) ->
        Map.put(score, :chaos_countdown, score.chaos_countdown)
    end
  end
end
