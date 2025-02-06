defmodule ViralSpiral.Room.Actions.Player.VoteToCancel do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :player, :string
    field :vote, :boolean
  end

  def changeset(vote, attrs) do
    vote
    |> cast(attrs, [:player, :vote])

    # todo add tests that player should start with `player_`?
  end
end
