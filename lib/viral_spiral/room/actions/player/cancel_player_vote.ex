defmodule ViralSpiral.Room.Actions.Player.CancelPlayerVote do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          from_id: String.t(),
          vote: boolean()
        }

  @primary_key false
  embedded_schema do
    field :from_id, :string
    field :vote, :boolean
  end

  def changeset(vote, attrs) do
    vote
    |> cast(attrs, [:from_id, :vote])
  end
end
