defmodule ViralSpiral.Room.Actions.Player.ViewSource do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :from_id, :string

    embeds_one :card, Card, primary_key: false do
      field :id, :string
      field :veracity, :boolean
    end
  end

  def changeset(view_source, attrs \\ %{}) do
    view_source
    |> cast(attrs, [:from_id])
    |> validate_required([:from_id])
    |> cast_embed(:card, with: &card_changeset/2)
  end

  def card_changeset(card, attrs) do
    card
    |> cast(attrs, [:id, :veracity])
    |> validate_required([:id, :veracity])
  end
end
