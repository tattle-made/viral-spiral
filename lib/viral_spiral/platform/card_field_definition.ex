defmodule ViralSpiral.Platform.CardFieldDefinition do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @valid_types ~w(string integer decimal boolean enum multi_enum)

  schema "card_field_definitions" do
    field :name, :string
    field :type, :string
    field :required, :boolean, default: false
    field :default_value, :string
    field :enum_values, {:array, :string}

    belongs_to :card_schema, ViralSpiral.Platform.CardSchema

    timestamps()
  end

  def changeset(field_def, attrs) do
    field_def
    |> cast(attrs, [:name, :type, :required, :default_value, :enum_values, :card_schema_id])
    |> validate_required([:name, :type, :card_schema_id])
    |> validate_inclusion(:type, @valid_types)
    |> validate_enum_values()
    |> foreign_key_constraint(:card_schema_id)
    |> unique_constraint([:card_schema_id, :name])
  end

  defp validate_enum_values(changeset) do
    case get_field(changeset, :type) do
      t when t in ["enum", "multi_enum"] ->
        validate_required(changeset, [:enum_values])

      _ ->
        changeset
    end
  end
end
