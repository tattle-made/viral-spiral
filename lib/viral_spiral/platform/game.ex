defmodule ViralSpiral.Platform.Game do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "games" do
    field :name, :string
    field :description, :string

    belongs_to :creator, ViralSpiral.Accounts.User, foreign_key: :created_by
    has_many :card_schemas, ViralSpiral.Platform.CardSchema
    has_many :memberships, ViralSpiral.Platform.GameMembership
    has_many :members, through: [:memberships, :user]
    has_many :invites, ViralSpiral.Platform.Invite

    timestamps()
  end

  def changeset(game, attrs) do
    game
    |> cast(attrs, [:name, :description, :created_by])
    |> validate_required([:name, :created_by])
    |> validate_length(:name, min: 1, max: 100)
    |> foreign_key_constraint(:created_by)
  end
end
