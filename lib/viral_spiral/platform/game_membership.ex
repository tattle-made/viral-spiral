defmodule ViralSpiral.Platform.GameMembership do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @roles [:owner, :collaborator, :playtester]

  schema "game_memberships" do
    field :role, Ecto.Enum, values: @roles

    belongs_to :game, ViralSpiral.Platform.Game
    belongs_to :user, ViralSpiral.Accounts.User
    belongs_to :inviter, ViralSpiral.Accounts.User, foreign_key: :invited_by

    timestamps()
  end

  def changeset(membership, attrs) do
    membership
    |> cast(attrs, [:role, :game_id, :user_id, :invited_by])
    |> validate_required([:role, :game_id, :user_id])
    |> validate_inclusion(:role, @roles)
    |> foreign_key_constraint(:game_id)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:invited_by)
    |> unique_constraint([:game_id, :user_id])
  end
end
