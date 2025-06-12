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
  def draw_type(%DrawConstraints{} = requirements) do
    type =
      case :rand.uniform() do
        a when a < 0.2 -> :bias
        a when a >= 0.2 and a < 0.6 -> :topical
        a when a >= 0.6 and a <= 1 -> :affinity
      end

    veracity =
      case :rand.uniform() do
        a when a < 1 - requirements.chaos / requirements.total_tgb -> true
        _ -> false
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
end
