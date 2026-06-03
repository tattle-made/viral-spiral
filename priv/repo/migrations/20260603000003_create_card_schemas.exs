defmodule ViralSpiral.Repo.Migrations.CreateCardSchemas do
  use Ecto.Migration

  def change do
    create table(:card_schemas, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :text
      add :game_id, references(:games, type: :binary_id, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:card_schemas, [:game_id])
    create unique_index(:card_schemas, [:game_id, :name])
  end
end
