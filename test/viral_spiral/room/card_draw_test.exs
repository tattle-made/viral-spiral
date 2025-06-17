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
end
