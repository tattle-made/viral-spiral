defmodule ViralSpiral.Repo.Migrations.CreateGameMemberships do
  use Ecto.Migration

  def change do
    create table(:game_memberships, primary_key: false) do
      add :id, :binary_id, primary_key: true
      # :owner | :collaborator | :playtester
      add :role, :string, null: false
      add :game_id, references(:games, type: :binary_id, on_delete: :delete_all), null: false
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :invited_by, references(:users, type: :binary_id, on_delete: :nilify_all)

      timestamps()
    end

    create unique_index(:game_memberships, [:game_id, :user_id])
    create index(:game_memberships, [:user_id])
  end
end
