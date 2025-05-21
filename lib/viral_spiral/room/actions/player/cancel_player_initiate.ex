defmodule ViralSpiral.Room.Actions.Player.CancelPlayerInitiate do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          from_id: String.t(),
          target_id: String.t(),
          affinity: :houseboat | :skub | :cat | :highfive | :sock
        }

  @primary_key false
  embedded_schema do
    field :from_id, :string
    field :target_id, :string
    field :affinity, Ecto.Enum, values: [:houseboat, :skub, :cat, :highfive, :socks]
  end

  def changeset(initiate_cancel, attrs) do
    initiate_cancel
    |> cast(attrs, [:from_id, :target_id, :affinity])
  end
end
