defmodule ViralSpiral.Room.GameSave do
  use Ecto.Schema
  import Ecto.Changeset
  alias ViralSpiral.Room.ErlangBinaryType

  @primary_key false
  schema "game_saves" do
    field :room_name, :string
    field :room_id, UXID
    field :data, ErlangBinaryType
    field :version, :integer

    timestamps()
  end

  def changeset(game_saves, attrs \\ %{}) do
    game_saves
    |> cast(attrs, [:room_name, :room_id, :data, :version])
    |> validate_required([:room_name, :data, :version])
  end
end
