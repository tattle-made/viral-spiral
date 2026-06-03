defmodule ViralSpiral.Repo.Migrations.CreateCardFieldDefinitions do
  use Ecto.Migration

  def change do
    create table(:card_field_definitions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      # "string" | "integer" | "boolean" | "enum"
      add :type, :string, null: false
      add :required, :boolean, null: false, default: false
      add :default_value, :string
      # populated when type is "enum", e.g. ["red", "blue", "yellow"]
      add :enum_values, :jsonb
      add :card_schema_id,
          references(:card_schemas, type: :binary_id, on_delete: :delete_all),
          null: false

      timestamps()
    end

    create index(:card_field_definitions, [:card_schema_id])
    create unique_index(:card_field_definitions, [:card_schema_id, :name])
  end
end
