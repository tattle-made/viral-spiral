defmodule ViralSpiral.Platform.CardSchema do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "card_schemas" do
    field :name, :string
    field :description, :string

    belongs_to :game, ViralSpiral.Platform.Game
    has_many :field_definitions, ViralSpiral.Platform.CardFieldDefinition
    has_many :cards, ViralSpiral.Platform.Card

    timestamps()
  end

  def changeset(card_schema, attrs) do
    card_schema
    |> cast(attrs, [:name, :description, :game_id])
    |> validate_required([:name, :game_id])
    |> validate_length(:name, min: 1, max: 100)
    |> foreign_key_constraint(:game_id)
    |> unique_constraint([:game_id, :name])
  end
end
