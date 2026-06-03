defmodule ViralSpiral.Repo.Migrations.CreateCards do
  use Ecto.Migration

  def change do
    create table(:cards, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :label, :string, null: false
      add :image_key, :string
      add :attributes, :jsonb, null: false, default: "{}"
      add :card_schema_id,
          references(:card_schemas, type: :binary_id, on_delete: :restrict),
          null: false
      add :created_by, references(:users, type: :binary_id, on_delete: :nilify_all)

      timestamps()
    end

    create index(:cards, [:card_schema_id])
    create index(:cards, [:created_by])
  end
end
