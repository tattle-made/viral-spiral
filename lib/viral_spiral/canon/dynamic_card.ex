defmodule ViralSpiral.Canon.DynamicCard do
  @moduledoc """
  Changes card text dynamically.

  Viral Spiral card texts have placeholders that get replaced at runtime by the game engine. We call these cards to be having dynamic text. Some examples of dynamic texts in cards are :
  - City revokes docking privileges for (other community) HoBos - "If they like the water so much they can stay there!
  - (oppressed community) ghetto vandalized, burned down during hilarious (popular affinity) day parade hooliganism

  Supported placeholders are : (other community), (dominant community), (oppressed community), (unpopular affinity), (popular affinity).

  ## Example Usage
  ```elixir
  headline = "People who like (unpopular affinity) are usually (dominant community)"
  matches = DynamicCard.find_placeholders(headline)
  replacements = %{
    unpopular_affinity: :skub,
    dominant_community: :red
  }
  new_headline = DynamicCard.replace_text(headline, matches, replacements)
  assert new_headline == "People who like Skub are usually Red"
  ```



  In practice you'd require visibility into the game state to create the replacements map show above. This falls under the responsibility of `ViralSpiral.Room.State.Analytics`
  """
  require IEx
  alias ViralSpiral.Bias
  alias ViralSpiral.Affinity

  @mappings [
    {"(other community)", :other_community},
    {"(Other community)", :Other_community},
    {"(dominant community)", :dominant_community},
    {"(Dominant community)", :Dominant_community},
    {"(oppressed community)", :oppressed_community},
    {"(Oppressed community)", :Oppressed_community},
    {"(unpopular affinity)", :unpopular_affinity},
    {"(popular affinity)", :popular_affinity},
    {"(player community)", :player_community}
  ]
  @string_to_atom_map Enum.reduce(@mappings, %{}, fn x, acc ->
                        Map.put(acc, elem(x, 0), elem(x, 1))
                      end)
  @atom_to_string_map Enum.reduce(@mappings, %{}, fn x, acc ->
                        Map.put(acc, elem(x, 1), elem(x, 0))
                      end)

  @type match ::
          :other_community
          | :dominant_community
          | :oppressed_community
          | :unpopular_affinity
          | :popular_affinity
  @type replacements :: %{
          optional(:other_community) => Bias.target(),
          optional(:dominant_community) => Bias.target(),
          optional(:oppressed_community) => Bias.target(),
          optional(:unpopular_affinity) => Affinity.target(),
          optional(:popular_affinity) => Affinity.target()
        }
  @regex_pattern ~r/(\(oppressed community\)|\(Oppressed community\)|\(popular affinity\)|\(unpopular affinity\)|\(other community\)|\(Other community\)|\(dominant community\)|\(Dominant community\)|\(player community\))/

  @doc """
  Find types of placeholders present in a card headline
  """
  @spec find_placeholders(String.t()) :: list(match())
  def find_placeholders(headline) do
    results =
      Regex.scan(@regex_pattern, headline)

    results
    |> Enum.map(&Enum.at(&1, 0))
    |> Enum.map(&@string_to_atom_map[&1])
  end

  @doc """
  Replace placeholders in a card headline.
  """
  @spec replace_text(String.t(), list(match), replacements()) :: String.t()
  def replace_text(headline, matches, replacements) do
    Enum.reduce(
      matches,
      headline,
      fn el, acc ->
        String.replace(acc, @atom_to_string_map[el], label(replacements[el]))
      end
    )
  end

  defp label(atom) do
    case atom do
      x when x in [:cat, :skub, :high_five, :houseboat, :sock] -> Affinity.label(atom)
      y when y in [:red, :yellow, :blue] -> Bias.label(atom)
    end
  end

  @doc """
  Returns `true` if the card headline contains placeholder for dynamic content.
  """
  def valid?(headline) do
    results =
      Regex.scan(@regex_pattern, headline)

    results
    |> Enum.map(&Enum.at(&1, 0))

    length(results) != 0
  end

  @doc """
  TODO : return a Card. Because this will need to update bias, affinity etc as well.
  """
  def patch(headline, identity_Stats) do
    matches = find_placeholders(headline)

    replace_text(headline, matches, identity_Stats)
  end
end
