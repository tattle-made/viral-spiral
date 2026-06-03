defmodule ViralSpiral.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    field :email, :string
    field :role, Ecto.Enum, values: [:designer, :player], default: :player
    field :password_hash, :string
    field :password, :string, virtual: true

    has_many :games, ViralSpiral.Platform.Game, foreign_key: :created_by
    has_many :cards, ViralSpiral.Platform.Card, foreign_key: :created_by

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :role, :password])
    |> validate_required([:email, :role])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/)
    |> validate_inclusion(:role, [:designer, :player])
    |> unique_constraint(:email)
    |> hash_password()
  end

  defp hash_password(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    put_change(changeset, :password_hash, Base.encode64(:crypto.hash(:sha256, password)))
  end

  defp hash_password(changeset), do: changeset
end
