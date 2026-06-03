defmodule ViralSpiral.Platform do
  @moduledoc """
  Context for the game platform — managing games, card schemas, field definitions, and cards.
  """

  import Ecto.Query
  alias ViralSpiral.Repo
  alias ViralSpiral.Platform.{Game, CardSchema, CardFieldDefinition, Card}

  # Games

  def list_games, do: Repo.all(Game)

  def get_game!(id), do: Repo.get!(Game, id)

  def create_game(attrs) do
    %Game{}
    |> Game.changeset(attrs)
    |> Repo.insert()
  end

  def update_game(%Game{} = game, attrs) do
    game
    |> Game.changeset(attrs)
    |> Repo.update()
  end

  def delete_game(%Game{} = game), do: Repo.delete(game)

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
