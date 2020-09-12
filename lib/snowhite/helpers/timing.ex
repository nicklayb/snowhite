defmodule Snowhite.Helpers.Timing do
  @moduledoc """
  Helper module to write milliseconds in a readable way. The goal of this module is help you quickly remember what milliseconds time you set instead of having to decode it yourself. Let's be honest, it's easier to understand 1h 30m and 10seconds than 5410000m than 5410000ms.

  It basically parses a syntax similar to 1h30m10s to a clock format ({1, 30, 10}). Then it can easily convert such clock to milliseconds. To quickly get ms out of a time string, you can use the sigil `~d()` (for duration) to help you.
  """
  @type milliseconds :: integer()
  @type time_unit :: :hours | :minutes | :seconds
  @type clock :: {integer(), integer(), integer()}

  @regex ~r/^(\d+h)?(\d+m)?(\d+s)?$/

  @doc """
  Most of the time you will rely on the sigil as it makes it easier to declare both compile time and runtime milliseconds.

  ## Exmaples
  ```
  iex> import Snowhite.Helpers.Timing
  iex> ~d(1h30m10s)
  5410000
  iex> ~d(1h)
  3600000
  iex> ~d(1h30m)
  5400000
  iex> ~d(15m10s)
  910000
  iex> ~d(1s)
  1000
  ```
  """
  @spec sigil_d(String.t(), list()) :: milliseconds()
  def sigil_d(string, _) do
    string
    |> parse!()
    |> clock_to_ms()
  end

  @doc """
  Parses a clock string to a clock tuple. Raises if the format doesn't match. It supports any combination in any order of `xh`, `xm` and `xs`.

  ## Examples
  ```
  iex> alias Snowhite.Helpers.Timing
  iex> Timing.parse!("1h20m")
  {1, 20, 0}
  iex> Timing.parse!("1x")
  ArgumentError "Expected clock format, received `1x`"
  ```
  """
  @spec parse!(String.t()) :: clock()
  def parse!(string) do
    if string == "" or not Regex.match?(@regex, string),
      do: raise("Expected clock format, received `#{string}`")

    [[_ | rest]] = Regex.scan(@regex, string)

    Enum.reduce(rest, zero(), fn string, {hours, minutes, seconds} ->
      case Integer.parse(string) do
        {int, "h"} -> {hours + int, minutes, seconds}
        {int, "m"} -> {hours, minutes + int, seconds}
        {int, "s"} -> {hours, minutes, seconds + int}
        _ -> {hours, minutes, seconds}
      end
    end)
  end

  @doc """
  Same as `parse!/1` but returns an ok tuple or an error tuple

  ## Examples
  ```
  iex> alias Snowhite.Helpers.Timing
  iex> Timing.parse!("1h20m")
  {:ok, {1, 20, 0}{}
  iex> Timing.parse!("1x")
  {:error, :invalid_format}
  ```
  """
  @spec parse(String.t()) :: {:error, :invalid_format} | {:ok, clock()}
  def parse(string) do
    result = parse!(string)
    {:ok, result}
  rescue
    _ ->
      {:error, :invalid_format}
  end

  @doc """
  Converts a clock tuple to milliseconds.

  ## Examples
  ```
  iex> alias Snowhite.Helpers.Timing
  iex> Timing.clock_to_ms({10, 3, 20})
  36200000
  iex> Timing.clock_to_ms({0, 0, 1})
  1000
  ```
  """
  @spec clock_to_ms(clock()) :: milliseconds()
  def clock_to_ms({hours, minutes, seconds}) do
    as_ms(hours, :hours) + as_ms(minutes, :minutes) + as_ms(seconds, :seconds)
  end

  @doc """
  Converts a given unit of time to milliseconds

  ## Examples

  ```
  iex> alias Snowhite.Helpers.Timing
  iex> Timing.as_ms(10, :hours)
  36000000
  iex> Timing.as_ms(10, :minutes)
  600000
  iex> Timing.as_ms(10, :seconds)
  10000
  ```
  """
  @spec as_ms(integer(), time_unit()) :: milliseconds()
  def as_ms(hours, :hours), do: as_ms(hours * 60, :minutes)
  def as_ms(minutes, :minutes), do: as_ms(minutes * 60, :seconds)
  def as_ms(seconds, :seconds), do: seconds * 1000

  @doc """
  Returns a zero clock `{0, 0, 0}`
  """
  @spec zero :: clock()
  def zero, do: {0, 0, 0}
end
