defmodule ViralSpiral.Room.Actions.Player.ViralSpiralInitiate do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :from_id, :string
    field :to, {:array, :string}
    field :bias, Ecto.Enum, values: [:red, :yellow, :blue]

    embeds_one :card, Card, primary_key: false do
      field :id, :string
      field :veracity, :boolean
    end
  end

  def changeset(initiate, attrs \\ %{}) do
    initiate
    |> cast(attrs, [:from_id, :to, :bias])
    |> validate_required([:from_id, :to, :bias])
    |> cast_embed(:card, with: &card_changeset/2)
  end

  def card_changeset(card, attrs) do
    card
    |> cast(attrs, [:id, :veracity])
    |> validate_required([:id, :veracity])
  end
end
