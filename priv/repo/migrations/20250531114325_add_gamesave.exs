defmodule ViralSpiral.Repo.Migrations.AddGamesave do
  use Ecto.Migration

  def change do
    create table(:game_saves, primary_key: false) do
      add :room_name, :string, primary_key: true, null: false, unique: true
      add :room_id, :string
      add :data, :binary
      add :version, :integer, null: false

      timestamps()
    end
  end
end
