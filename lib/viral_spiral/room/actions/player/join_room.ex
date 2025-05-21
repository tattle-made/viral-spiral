defmodule ViralSpiral.Room.Actions.Player.JoinRoom do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          player_name: String.t()
        }

  @primary_key false
  embedded_schema do
    field :player_name, :string
  end

  def changeset(join_room, attrs \\ %{}) do
    join_room
    |> cast(attrs, [:player_name])
    |> validate_required([:player_name])
  end
end
