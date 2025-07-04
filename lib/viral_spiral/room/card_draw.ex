defmodule ViralSpiral.Room.CardDraw do
  alias ViralSpiral.Room.DrawConstraints

  @doc """
  Determines what type of card to draw.

  Returns a tuple that should be a valid key of a Store.

  [type: :topical, veracity: false, tgb: 4]
  [type: :topical, veracity: true, tgb: 1]
  [type: :affinity, veracity: true, target: :skub, tgb: 2]
  [type: :bias, veracity: false, target: :yellow, tgb: 0] and so on

  deprecated : [
    {:conflated, false, nil},
    {:topical, false, nil},
    {:topical, true, nil},
    {:affinity, false, :cat},
    {:affinity, false, :sock},
    {:affinity, true, :cat},
    {:affinity, true, :sock},
    {:bias, false, :red},
    {:bias, false, :yellow},
    {:bias, true, :red},
    {:bias, true, :yellow}
  ]

  requirements = %DrawTypeRequirements{
    chaos: 4,
    total_tgb: 10,
    biases: [:red, :blue],
    affinities: [:cat, :sock],
    current_player: %{
      identity: :blue
    }
  }
  """

  @veracity_threshold 4

  def draw_type(%DrawConstraints{} = requirements) do
    # dynamic bias probability increase's from 0.2 to 0.7 as chaos goes from 0 to 10
    bias_prob = 0.2 + 0.05 * requirements.chaos
    remaining_prob = 1 - bias_prob

    type =
      case :rand.uniform() do
        a when a < bias_prob ->
          :bias

        a when a < bias_prob + remaining_prob / 2 ->
          :topical

        _ ->
          :affinity
      end

    veracity =
      case requirements.chaos do
        chaos when chaos <= @veracity_threshold ->
          true

        _ ->
          case :rand.uniform() do
            a when a < 1 - requirements.chaos / requirements.total_tgb -> true
            _ -> false
          end
      end

    target =
      case type do
        :bias -> pick_one(requirements.biases, exclude: requirements.current_player.identity)
        :affinity -> pick_one(requirements.affinities)
        :topical -> nil
      end

    {}
    |> Tuple.insert_at(0, type)
    |> then(fn val ->
      case target do
        nil -> Tuple.insert_at(val, 1, veracity) |> Tuple.insert_at(2, nil)
        _ -> Tuple.insert_at(val, 1, veracity) |> Tuple.insert_at(2, target)
      end
    end)
  end

  defp pick_one(list, opts \\ []) do
    exclude = opts[:exclude]
    list = list |> Enum.filter(&(&1 != exclude))

    ix = :rand.uniform(length(list)) - 1
    Enum.at(list, ix)
  end

  @identities [:red, :blue, :yellow]
  def assign_player_identity(names) do
    base_distribution = Enum.take(Stream.cycle(@identities), length(names))
    shuffled_distribution = Enum.shuffle(base_distribution)
    Enum.zip(names, shuffled_distribution)
  end
end
