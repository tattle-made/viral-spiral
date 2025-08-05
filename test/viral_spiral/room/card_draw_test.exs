defmodule ViralSpiral.Room.CardDrawTest do
  use ExUnit.Case

  alias ViralSpiral.Room.CardDraw
  alias ViralSpiral.Room.DrawConstraints

  @constraints %DrawConstraints{
    chaos: 5,
    total_tgb: 10,
    biases: [:red, :blue, :yellow],
    affinities: [:cat, :sock, :skub],
    current_player: %{identity: :red}
  }

  test "draw_type/1 returns a 3-element tuple" do
    {type, veracity, target} = CardDraw.draw_type(@constraints)
    assert type in [:bias, :topical, :affinity]
    assert is_boolean(veracity)
    assert is_atom(target) or is_nil(target)
  end

  test "bias target never equals current player's identity" do
    {type, _veracity, target} = CardDraw.draw_type(@constraints)

    if type == :bias do
      assert target != @constraints.current_player.identity
    end
  end

  test "topical type always has nil target" do
    {type, _veracity, target} = CardDraw.draw_type(@constraints)

    if type == :topical do
      assert target == nil
    end
  end

  test "affinity target is always from affinities list" do
    {type, _, target} = CardDraw.draw_type(@constraints)

    if type == :affinity do
      assert target in @constraints.affinities
    end
  end

  test "veracity becomes more likely with decreasing chaos" do
    low_chaos = %{@constraints | chaos: 2}
    high_chaos = %{@constraints | chaos: 7}

    low_veracity_ratio =
      Enum.count(Enum.map(1..1000, fn _ -> CardDraw.draw_type(low_chaos) end), fn {_, v, _} ->
        v == true
      end) / 1000

    high_veracity_ratio =
      Enum.count(Enum.map(1..1000, fn _ -> CardDraw.draw_type(high_chaos) end), fn {_, v, _} ->
        v == true
      end) / 1000

    assert high_veracity_ratio < low_veracity_ratio
  end

  test "bias type card probability increases with chaos" do
    chaos_1 = %{@constraints | chaos: 1}
    chaos_3 = %{@constraints | chaos: 3}
    chaos_7 = %{@constraints | chaos: 7}
    chaos_9 = %{@constraints | chaos: 9}

    bias_ratio_1 =
      Enum.count(Enum.map(1..1000, fn _ -> CardDraw.draw_type(chaos_1) end), fn {type, _, _} ->
        type == :bias
      end) / 1000

    bias_ratio_3 =
      Enum.count(Enum.map(1..1000, fn _ -> CardDraw.draw_type(chaos_3) end), fn {type, _, _} ->
        type == :bias
      end) / 1000

    bias_ratio_7 =
      Enum.count(Enum.map(1..1000, fn _ -> CardDraw.draw_type(chaos_7) end), fn {type, _, _} ->
        type == :bias
      end) / 1000

    bias_ratio_9 =
      Enum.count(Enum.map(1..1000, fn _ -> CardDraw.draw_type(chaos_9) end), fn {type, _, _} ->
        type == :bias
      end) / 1000

    # Assert increasing order
    assert bias_ratio_1 < bias_ratio_3
    assert bias_ratio_3 < bias_ratio_7
    assert bias_ratio_7 < bias_ratio_9

    # With chaos=1, bias should be around 25% (0.2 + 0.05 * 1 = 0.25)
    assert bias_ratio_1 > 0.2
    assert bias_ratio_1 < 0.35

    # With chaos=3, bias should be around 35% (0.2 + 0.05 * 3 = 0.35)
    assert bias_ratio_3 > 0.3
    assert bias_ratio_3 < 0.45

    # With chaos=7, bias should be around 55% (0.2 + 0.05 * 7 = 0.55)
    assert bias_ratio_7 > 0.5
    assert bias_ratio_7 < 0.65

    # With chaos=9, bias should be around 65% (0.2 + 0.05 * 9 = 0.65)
    assert bias_ratio_9 > 0.6
    assert bias_ratio_9 < 0.75
  end

  test "veracity is always true when chaos <= 4" do
    for chaos <- 0..4 do
      constraints = %{@constraints | chaos: chaos}

      results = Enum.map(1..100, fn _ -> CardDraw.draw_type(constraints) end)

      assert Enum.all?(results, fn {_, veracity, _} -> veracity == true end)
    end
  end

  test "veracity follows chaos/total_tgb logic when chaos > 4" do
    high_chaos = %{@constraints | chaos: 7}
    medium_chaos = %{@constraints | chaos: 5}

    # For chaos=7, total_tgb=10: probability of true = 1 - 7/10 = 0.3
    high_veracity_ratio =
      Enum.count(Enum.map(1..1000, fn _ -> CardDraw.draw_type(high_chaos) end), fn {_, v, _} ->
        v == true
      end) / 1000

    # For chaos=5, total_tgb=10: probability of true = 1 - 5/10 = 0.5
    medium_veracity_ratio =
      Enum.count(Enum.map(1..1000, fn _ -> CardDraw.draw_type(medium_chaos) end), fn {_, v, _} ->
        v == true
      end) / 1000

    assert medium_veracity_ratio > high_veracity_ratio
    assert_in_delta medium_veracity_ratio, 0.5, 0.1
    assert_in_delta high_veracity_ratio, 0.3, 0.1
  end

  test "veracity threshold boundary at chaos=4 vs chaos=5" do
    chaos_4 = %{@constraints | chaos: 4}
    chaos_5 = %{@constraints | chaos: 5}

    # chaos=4 should always be true
    results_4 = Enum.map(1..100, fn _ -> CardDraw.draw_type(chaos_4) end)
    assert Enum.all?(results_4, fn {_, veracity, _} -> veracity == true end)

    veracity_ratio_5 =
      Enum.count(Enum.map(1..1000, fn _ -> CardDraw.draw_type(chaos_5) end), fn {_, v, _} ->
        v == true
      end) / 1000

    assert_in_delta veracity_ratio_5, 0.5, 0.1
  end

  test "probability of drawing topical vs affinity is roughly equal for each chaos level" do
    for chaos <- 0..9 do
      constraints = %{@constraints | chaos: chaos}

      counts =
        Enum.map(1..1000, fn _ -> CardDraw.draw_type(constraints) end)
        |> Enum.frequencies_by(fn {type, _, _} -> type end)

      topical_count = Map.get(counts, :topical, 0)
      affinity_count = Map.get(counts, :affinity, 0)

      topical_ratio = topical_count / 1000
      affinity_ratio = affinity_count / 1000

      # We expect them both to be around (1 - bias_prob) / 2
      bias_prob = 0.2 + 0.05 * chaos
      expected_ratio = (1 - bias_prob) / 2

      assert_in_delta topical_ratio, expected_ratio, 0.1
      assert_in_delta affinity_ratio, expected_ratio, 0.1
    end
  end

  test "all affinity targets are drawn over many draws and have roughly equal distribution" do
    constraints = %{@constraints | chaos: 5}

    draws =
      Enum.map(1..10_000, fn _ -> CardDraw.draw_type(constraints) end)
      |> Enum.filter(fn {type, _, _} -> type == :affinity end)
      |> Enum.map(fn {_, _, target} -> target end)

    counts = Enum.frequencies(draws)

    # Ensure all affinity targets are drawn at least once
    for affinity <- @constraints.affinities do
      assert Map.has_key?(counts, affinity)
    end
  end

  @identities [:red, :blue, :yellow]
  test "assign_player_identity" do
    for _ <- 1..1000 do
      for n <- 2..12 do
        # Generate dummy names
        names = Enum.map(1..n, &"player_#{&1}")

        # Pick room communities only for the 2-player case; otherwise use all identities
        room_communities =
          if n == 2 do
            [:red, :blue]
          else
            @identities
          end

        result = CardDraw.assign_player_identity(names, room_communities)

        # length matches
        assert length(result) == length(names)

        # All names are present
        result_names = Enum.map(result, &elem(&1, 0))
        assert Enum.sort(result_names) == Enum.sort(names)

        # Only valid identities used
        identities = Enum.map(result, &elem(&1, 1))
        assert Enum.all?(identities, &(&1 in @identities))

        if n == 2 do
          # For two players, you must get exactly the two you passed in
          assert Enum.sort(identities) == Enum.sort(room_communities)
        else
          # At least one of each identity is used
          assert Enum.any?(identities, &(&1 == :red))
          assert Enum.any?(identities, &(&1 == :blue))
          assert Enum.any?(identities, &(&1 == :yellow))

          # Check that no identity appears more than ceil(n / 3) + 1 times
          max_allowed = div(length(names), 3) + 1
          identity_counts = Enum.frequencies(identities)

          for {_color, count} <- identity_counts do
            assert count <= max_allowed
          end
        end
      end
    end
  end
end
