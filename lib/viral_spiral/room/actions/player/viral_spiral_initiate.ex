defmodule ViralSpiral.Room.Actions.Player.ViralSpiralInitiate do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key false
  embedded_schema do
    field :from_id, :string
    field :to_id, {:array, :string}

    embeds_one :card, Card, primary_key: false do
      field :id, :string
      field :veracity, :boolean
    end
  end

  def changeset(action, attrs \\ %{}) do
    action
    |> cast(attrs, [:from_id, :to_id])
    |> validate_required([:from_id, :to_id])
    |> cast_embed(:card, with: &card_changeset/2)
  end

  def card_changeset(card, attrs) do
    card
    |> cast(attrs, [:id, :veracity])
    |> validate_required([:id, :veracity])
  end
end
