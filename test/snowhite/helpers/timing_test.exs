defmodule Snowhite.Helpers.TimingTest do
  use Snowhite.TestCase

  alias Snowhite.Helpers.Timing

  @valid_values [
    {"1h", {1, 0, 0}, 3_600_000},
    {"1m", {0, 1, 0}, 60000},
    {"1s", {0, 0, 1}, 1000},
    {"1h1m1s", {1, 1, 1}, 3_661_000},
    {"1h1m", {1, 1, 0}, 3_660_000},
    {"6h", {6, 0, 0}, 21_600_000},
    {"4h3s", {4, 0, 3}, 14_403_000},
    {"12h22m18s", {12, 22, 18}, 44_538_000},
    {"12m18s", {0, 12, 18}, 738_000}
  ]
  @invalid_values [
    "1ss",
    "1t",
    "xt",
    "",
    "some long string",
    "-1s"
  ]
  describe "parse!/1" do
    test "parses a valid string" do
      Enum.all?(@valid_values, fn {value, clock, _} ->
        assert clock == Timing.parse!(value)
      end)
    end

    test "raises with an invalid string" do
      Enum.each(@invalid_values, fn value ->
        assert_raise RuntimeError, fn -> Timing.parse!(value) end
      end)
    end
  end

  describe "parse/1" do
    test "parses a valid string with :ok tuple" do
      Enum.all?(@valid_values, fn {value, clock, _} ->
        assert {:ok, ^clock} = Timing.parse(value)
      end)
    end

    test "returns :error tuple with an invalid string" do
      Enum.each(@invalid_values, fn value ->
        assert {:error, :invalid_format} = Timing.parse(value)
      end)
    end
  end

  describe "clock_to_ms/1" do
    test "calculates clock value in milliseconds" do
      Enum.each(@valid_values, fn {_, clock, milliseconds} ->
        assert milliseconds == Timing.clock_to_ms(clock)
      end)
    end
  end

  describe "as_ms/2" do
    @range 1..10
    test "converts hours to ms" do
      Enum.each(@range, fn value ->
        assert value * 60 * 60 * 1000 == Timing.as_ms(value, :hours)
      end)
    end

    test "converts minutes to ms" do
      Enum.each(@range, fn value ->
        assert value * 60 * 1000 == Timing.as_ms(value, :minutes)
      end)
    end

    test "converts seconds to ms" do
      Enum.each(@range, fn value ->
        assert value * 1000 == Timing.as_ms(value, :seconds)
      end)
    end
  end

  describe "zero/0" do
    test "returns a zero clock" do
      assert {0, 0, 0} = Timing.zero()
    end
  end

  describe "sigil_d/2" do
    test "usable as a sigil" do
      import Snowhite.Helpers.Timing

      assert 1000 = ~d(1s)
    end

    test "parses valid values" do
      Enum.each(@valid_values, fn {value, _, milliseconds} ->
        assert milliseconds == Timing.sigil_d(value, [])
      end)
    end

    test "raises invalid values" do
      Enum.each(@invalid_values, fn value ->
        assert_raise RuntimeError, fn -> Timing.sigil_d(value, []) end
      end)
    end
  end
end
