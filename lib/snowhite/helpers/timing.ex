defmodule Snowhite.Helpers.Timing do
  @type milliseconds :: integer()
  @type time_unit :: :hours | :minutes | :seconds
  @type clock :: {integer(), integer(), integer()}

  @regex ~r/^(\d+h)?(\d+m)?(\d+s)?$/

  @spec sigil_d(String.t(), list()) :: milliseconds()
  def sigil_d(string, _) do
    string
    |> parse!()
    |> clock_to_ms()
  end

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

  @spec parse(String.t()) :: {:error, :invalid_format} | {:ok, clock()}
  def parse(string) do
    result = parse!(string)
    {:ok, result}
  rescue
    _ ->
      {:error, :invalid_format}
  end

  @spec clock_to_ms(clock()) :: milliseconds()
  def clock_to_ms({hours, minutes, seconds}) do
    as_ms(hours, :hours) + as_ms(minutes, :minutes) + as_ms(seconds, :seconds)
  end

  @spec as_ms(integer(), time_unit()) :: milliseconds()
  def as_ms(hours, :hours), do: as_ms(hours * 60, :minutes)
  def as_ms(minutes, :minutes), do: as_ms(minutes * 60, :seconds)
  def as_ms(seconds, :seconds), do: seconds * 1000

  @spec zero :: clock()
  def zero, do: {0, 0, 0}
end
