defmodule ViralSpiral.Room.State.Room do
  @moduledoc """
  ## Example

  """
  alias ViralSpiral.Room.State.Room
  alias ViralSpiral.Room.State.Change

  defstruct chaos_countdown: 10

  @type t :: %__MODULE__{
          chaos_countdown: integer()
        }

  @doc """
  Create a new Room with default values.
  """
  @spec new() :: t()
  def new() do
    %Room{}
  end

  @doc """
  Reduce the chaos countdown by 1.
  """
  @spec countdown(t()) :: t()
  def countdown(%Room{} = room) do
    %{room | chaos_countdown: room.chaos_countdown - 1}
  end

  defimpl Change do
    alias ViralSpiral.Room.State.Room

    @doc """
    Change state of a Room.
    """
    @spec apply_change(Room.t(), keyword()) :: Room.t()
    def apply_change(%Room{} = score, opts) do
      opts = Keyword.validate!(opts, offset: 0)

      case opts[:offset] do
        x when is_integer(x) ->
          Map.put(score, :chaos_countdown, score.chaos_countdown + opts[:offset])

        y when is_bitstring(y) ->
          Map.put(score, :chaos_countdown, score.chaos_countdown)
      end
    end
  end
end
