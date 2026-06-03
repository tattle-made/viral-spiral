defmodule ViralSpiral.Platform.Invite do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @invitable_roles [:collaborator, :playtester]

  schema "invites" do
    field :token, :string
    field :email, :string
    field :role, Ecto.Enum, values: @invitable_roles
    field :accepted_at, :utc_datetime
    field :expires_at, :utc_datetime

    belongs_to :game, ViralSpiral.Platform.Game
    belongs_to :inviter, ViralSpiral.Accounts.User, foreign_key: :invited_by

    timestamps()
  end

  def changeset(invite, attrs) do
    invite
    |> cast(attrs, [:email, :role, :game_id, :invited_by, :expires_at])
    |> validate_required([:email, :role, :game_id, :invited_by, :expires_at])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+\.[^\s]+$/)
    |> validate_inclusion(:role, @invitable_roles)
    |> put_token()
    |> foreign_key_constraint(:game_id)
    |> foreign_key_constraint(:invited_by)
    |> unique_constraint(:token)
  end

  def accept_changeset(invite) do
    invite
    |> change(accepted_at: DateTime.utc_now() |> DateTime.truncate(:second))
  end

  def expired?(%__MODULE__{expires_at: expires_at}) do
    DateTime.compare(DateTime.utc_now(), expires_at) == :gt
  end

  def accepted?(%__MODULE__{accepted_at: accepted_at}), do: not is_nil(accepted_at)

  defp put_token(%Ecto.Changeset{} = changeset) do
    token = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
    put_change(changeset, :token, token)
  end
end
