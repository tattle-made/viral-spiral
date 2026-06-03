defmodule ViralSpiral.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :text
      add :created_by, references(:users, type: :binary_id, on_delete: :nilify_all)

      timestamps()
    end

    create index(:games, [:created_by])
  end
end
