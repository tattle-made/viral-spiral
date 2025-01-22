defmodule ViralSpiral.Room.Actions.Player.TurnToFake do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :player_id, :string

    embeds_one :card, Card, primary_key: false do
      field :id, :string
      field :type, Ecto.Enum, values: [:affinity, :topical, :bias]
      field :veracity, :boolean

      field :target, Ecto.Enum,
        values: [:houseboat, :skub, :cat, :highfive, :socks, :yellow, :red, :blue]
    end
  end

  def changeset(turn_to_fake, attrs) do
    turn_to_fake
    |> cast(attrs, [:player_id])
    |> cast_embed(:card, with: &card_changeset/2)
  end

  def card_changeset(card, attrs) do
    card
    |> cast(attrs, [:id, :type, :veracity, :target])
  end
end
