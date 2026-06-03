defmodule ViralSpiral.Platform.Card do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "cards" do
    field :label, :string
    field :image_key, :string
    field :attributes, :map, default: %{}

    belongs_to :card_schema, ViralSpiral.Platform.CardSchema
    belongs_to :creator, ViralSpiral.Accounts.User, foreign_key: :created_by

    timestamps()
  end

  def changeset(card, attrs) do
    card
    |> cast(attrs, [:id, :label, :image_key, :attributes, :card_schema_id, :created_by])
    |> validate_required([:label, :card_schema_id])
    |> foreign_key_constraint(:card_schema_id)
    |> foreign_key_constraint(:created_by)
  end

  def validate_attributes(changeset, field_definitions) do
    attributes = get_field(changeset, :attributes) || %{}

    errors =
      field_definitions
      |> Enum.filter(& &1.required)
      |> Enum.reject(&Map.has_key?(attributes, &1.name))
      |> Enum.map(&{"attributes", {"field '#{&1.name}' is required", []}})

    Enum.reduce(errors, changeset, fn {field, error}, acc ->
      add_error(acc, String.to_atom(field), elem(error, 0))
    end)
  end
end
