defmodule ViralSpiral.Repo.Migrations.CreateInvites do
  use Ecto.Migration

  def change do
    create table(:invites, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :token, :string, null: false
      add :email, :string, null: false
      # :collaborator | :playtester
      add :role, :string, null: false
      add :game_id, references(:games, type: :binary_id, on_delete: :delete_all), null: false
      add :invited_by, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :accepted_at, :utc_datetime
      add :expires_at, :utc_datetime, null: false

      timestamps()
    end

    create unique_index(:invites, [:token])
    create index(:invites, [:email])
    create index(:invites, [:game_id])
  end
end
