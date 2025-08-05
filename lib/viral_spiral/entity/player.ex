defmodule ViralSpiral.Entity.Player do
  @moduledoc """
  Create and update Player Score.

  ## Example
  iex> player_score = %ViralSpiral.Game.Score.Player{
    biases: %{red: 0, blue: 0},
    affinities: %{cat: 0, sock: 0},
    clout: 0
  }
  """

  alias ViralSpiral.Entity.Player
  alias ViralSpiral.Canon.Card.Sparse
  alias ViralSpiral.Bias, as: ViralSpiralBias
  alias ViralSpiral.Affinity, as: ViralSpiralAffinity
  import Ecto.Changeset

  defstruct id: nil,
            biases: %{},
            affinities: %{},
            clout: 0,
            name: "",
            identity: nil,
            hand: [],
            active_cards: [],
            open_articles: %{}

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          identity: ViralSpiralBias.target(),
          clout: integer(),
          biases: %{optional(ViralSpiralBias.target()) => integer()},
          affinities: %{optional(ViralSpiralAffinity.target()) => integer()},
          hand: list(Sparse.t()),
          active_cards: list(Sparse.t()),
          open_articles: %{headline: String.t(), description: String.t()}
        }

  # Enable Ecto cast and validation features on this struct.
  # This allows us to create valid Player structs within the app and tests.
  # todo : fix the :any type to limit it to atoms atleast
  @types %{
    id: :string,
    name: :string,
    identity: :any,
    clout: :integer,
    biases: {:array, :any},
    affinities: {:array, :any}
  }

  @doc """
  Create a Player by passing maps with valid values.
  """
  def new(attrs \\ %{}) do
    uxid = Application.get_env(:viral_spiral, :uxid)
    id = attrs[:id] || uxid.generate!(prefix: "player", size: :small)

    changeset =
      {%{}, @types}
      |> cast(attrs, Map.keys(@types))
      |> validate_affinity()
      |> validate_bias()

    valid_attrs =
      case changeset.valid? do
        true -> apply_changes(changeset)
        false -> raise "Invalid parameters were passed while creating a Player"
      end

    biases = Enum.reduce(valid_attrs.biases, %{}, fn bias, acc -> Map.put(acc, bias, 0) end)

    affinities =
      Enum.reduce(valid_attrs.affinities, %{}, fn affin, acc -> Map.put(acc, affin, 0) end)

    valid_attrs =
      valid_attrs
      |> Map.put(:biases, biases)
      |> Map.put(:affinities, affinities)
      |> Map.put(:id, id)

    struct(Player, valid_attrs)
  end

  defp validate_bias(changeset) do
    validate_change(changeset, :biases, fn field, value ->
      atoms = Enum.filter(value, &is_atom(&1))
      valid_atoms = Enum.filter(atoms, &ViralSpiralBias.valid?(&1))

      case length(valid_atoms) == length(value) do
        true -> []
        false -> [{field, "invalid bias passed"}]
      end
    end)
  end

  defp validate_affinity(changeset) do
    validate_change(changeset, :affinities, fn field, value ->
      atoms = Enum.filter(value, &is_atom(&1))
      valid_atoms = Enum.filter(atoms, &ViralSpiralAffinity.valid?(&1))

      case length(valid_atoms) == length(value) do
        true -> []
        false -> [{field, "invalid affinity passed"}]
      end
    end)
  end

  def set_name(%Player{} = player, name) do
    %{player | name: name}
  end

  def viralspiral_target_bias(%Player{} = player, threshold) do
    target_bias = Enum.filter(player.biases, fn bias -> elem(bias, 1) >= threshold end)

    case target_bias do
      [] -> nil
      x -> x |> hd |> elem(0)
    end
  end

  defimpl ViralSpiral.Entity.Change do
    require IEx
    alias ViralSpiral.Entity.Player.Changes.CloseArticle
    alias ViralSpiral.Entity.Change.UndefinedChange
    alias ViralSpiral.Canon.Card.Sparse
    alias ViralSpiral.Entity.Player

    alias ViralSpiral.Entity.Player.Changes.{
      Clout,
      Affinity,
      Bias,
      AddActiveCard,
      RemoveFromHand,
      AddToHand,
      RemoveActiveCard,
      MakeActiveCardFake,
      ViewArticle
    }

    alias ViralSpiral.Entity.Player.Exceptions.{
      ActiveCardDoesNotExist,
      DuplicateActiveCardException
    }

    @type change_types ::
            %Clout{}
            | %Affinity{}
            | %Bias{}
            | %AddToHand{}
            | %RemoveFromHand{}
            | %AddActiveCard{}
            | %RemoveActiveCard{}
            | %MakeActiveCardFake{}
            | %ViewArticle{}

    @spec change(Player.t(), change_types()) :: Player.t()
    def change(%Player{} = player, %Clout{} = change) do
      case player.clout + change.offset do
        invalid_clout when invalid_clout < 0 -> player
        new_valid_clout -> %{player | clout: new_valid_clout}
      end
    end

    def change(%Player{} = player, %Affinity{} = change) do
      current_affinity = player.affinities[change.target]
      new_affinities = Map.put(player.affinities, change.target, current_affinity + change.offset)

      %{player | affinities: new_affinities}
    end

    def change(%Player{} = player, %Bias{} = change) do
      case Map.get(player.biases, change.target) do
        nil ->
          # If a player passes a card with a bias against their own identity, do nothing
          player

        current_bias ->
          new_biases = Map.put(player.biases, change.target, current_bias + change.offset)
          %{player | biases: new_biases}
      end
    end

    def change(%Player{} = player, %AddToHand{} = change) do
      Map.put(player, :hand, player.hand ++ [change.card])
    end

    def change(%Player{} = player, %RemoveFromHand{} = change) do
      Map.put(player, :hand, List.delete(player.hand, change.card))
    end

    def change(%Player{} = player, %AddActiveCard{} = change) do
      card = change.card

      case Enum.find(player.active_cards, &(&1.id == card.id)) do
        nil -> Map.put(player, :active_cards, player.active_cards ++ [card])
        _ -> raise DuplicateActiveCardException
      end
    end

    def change(%Player{} = player, %RemoveActiveCard{} = change) do
      card = change.card

      case Enum.find(
             player.active_cards,
             &(&1.id == card.id and &1.veracity == card.veracity)
           ) do
        nil ->
          raise ActiveCardDoesNotExist

        _ ->
          Map.put(player, :active_cards, List.delete(player.active_cards, card))
      end
    end

    def change(%Player{} = player, %MakeActiveCardFake{} = change) do
      card_id = change.card.id
      new_card = change.card

      ix = Enum.find_index(player.active_cards, fn card -> card.id == card_id end)

      active_cards =
        List.replace_at(
          player.active_cards,
          ix,
          Sparse.new(card_id, new_card.veracity)
        )

      %{player | active_cards: active_cards}
    end

    def change(%Player{} = player, %ViewArticle{} = change) do
      open_articles = Map.put(player.open_articles, change.card, change.article)
      %{player | open_articles: open_articles}
    end

    def change(%Player{} = player, %CloseArticle{} = change) do
      open_articles = Map.delete(player.open_articles, change.card)
      %{player | open_articles: open_articles}
    end

    def change(%Player{} = _player, _change) do
      raise UndefinedChange,
        message: "You are trying to make an unsupported change to this Player"
    end
  end
end
