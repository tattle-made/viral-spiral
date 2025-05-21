defmodule ViralSpiral.Room.Actions.Player.ReserveRoom do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          player_name: String.t()
        }

  @primary_key false
  embedded_schema do
    field :player_name, :string
  end

  def changeset(reserve_room, attrs \\ %{}) do
    reserve_room
    |> cast(attrs, [:player_name])
    |> validate_required([:player_name])
  end
end
