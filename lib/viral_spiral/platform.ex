defmodule ViralSpiral.Platform do
  @moduledoc """
  Context for the game platform — managing games, card schemas, field definitions, and cards.
  """

  import Ecto.Query
  alias Ecto.Multi
  alias ViralSpiral.Repo
  alias ViralSpiral.Platform.{Game, GameMembership, CardSchema, CardFieldDefinition, Card}

  # Games

  def list_games, do: Repo.all(Game)

  def list_games_for_user(user_id) do
    GameMembership
    |> where([m], m.user_id == ^user_id)
    |> preload(:game)
    |> Repo.all()
    |> Enum.map(& &1.game)
  end

  def get_game!(id), do: Repo.get!(Game, id)

  @doc "Create a game and automatically assign the creator as :owner."
  def create_game(attrs) do
    Multi.new()
    |> Multi.insert(:game, Game.changeset(%Game{}, attrs))
    |> Multi.insert(:membership, fn %{game: game} ->
      GameMembership.changeset(%GameMembership{}, %{
        game_id: game.id,
        user_id: game.created_by,
        role: :owner
      })
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{game: game}} -> {:ok, game}
      {:error, _step, changeset, _changes} -> {:error, changeset}
    end
  end

  def update_game(%Game{} = game, attrs) do
    game
    |> Game.changeset(attrs)
    |> Repo.update()
  end

  def delete_game(%Game{} = game), do: Repo.delete(game)

  # Memberships

  def get_membership(user_id, game_id) do
    Repo.get_by(GameMembership, user_id: user_id, game_id: game_id)
  end

  def membership_role(user_id, game_id) do
    case get_membership(user_id, game_id) do
      nil -> nil
      m -> m.role
    end
  end

  # Card Schemas

  def list_card_schemas(game_id) do
    CardSchema
    |> where([cs], cs.game_id == ^game_id)
    |> Repo.all()
  end

  def get_card_schema!(id), do: Repo.get!(CardSchema, id)

  def create_card_schema(attrs) do
    %CardSchema{}
    |> CardSchema.changeset(attrs)
    |> Repo.insert()
  end

  def update_card_schema(%CardSchema{} = schema, attrs) do
    schema
    |> CardSchema.changeset(attrs)
    |> Repo.update()
  end

  def delete_card_schema(%CardSchema{} = schema), do: Repo.delete(schema)

  # Card Field Definitions

  def list_field_definitions(card_schema_id) do
    CardFieldDefinition
    |> where([fd], fd.card_schema_id == ^card_schema_id)
    |> Repo.all()
  end

  def create_field_definition(attrs) do
    %CardFieldDefinition{}
    |> CardFieldDefinition.changeset(attrs)
    |> Repo.insert()
  end

  def update_field_definition(%CardFieldDefinition{} = fd, attrs) do
    fd
    |> CardFieldDefinition.changeset(attrs)
    |> Repo.update()
  end

  def delete_field_definition(%CardFieldDefinition{} = fd), do: Repo.delete(fd)

  # Cards

  def list_cards(card_schema_id) do
    Card
    |> where([c], c.card_schema_id == ^card_schema_id)
    |> Repo.all()
  end

  def get_card!(id), do: Repo.get!(Card, id)

  def create_card(attrs) do
    schema_id = Map.get(attrs, :card_schema_id) || Map.get(attrs, "card_schema_id")
    field_definitions = if schema_id, do: list_field_definitions(schema_id), else: []

    %Card{}
    |> Card.changeset(attrs)
    |> Card.validate_attributes(field_definitions)
    |> Repo.insert()
  end

  def update_card(%Card{} = card, attrs) do
    card_schema_id = card.card_schema_id
    field_definitions = list_field_definitions(card_schema_id)

    card
    |> Card.changeset(attrs)
    |> Card.validate_attributes(field_definitions)
    |> Repo.update()
  end

  def delete_card(%Card{} = card), do: Repo.delete(card)
end
