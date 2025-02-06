defmodule ViralSpiral.Room.Actions.Player.InitiateCancel do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :from, :string
    field :target, :string
    field :affinity, Ecto.Enum, values: [:houseboat, :skub, :cat, :highfive, :socks]
  end

  def changeset(initiate_cancel, attrs) do
    initiate_cancel
    |> cast(attrs, [:from, :target, :affinity])
  end
end
