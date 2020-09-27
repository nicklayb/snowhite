defmodule Snowhite.Modules.CalendarBuilder do
  @moduledoc """
  Builds a month calendar from a given date.
  """
  @days_in_week 7
  @type date :: Timex.Types.datetime() | Timex.Types.date()
  @type calendar :: [week()]
  @type week :: [date(), ...]

  @doc """
  Build the month calendar for the given date. It also pads days before and after the given month to give a full 7-day per week list of list of date.
  """
  @spec build_month(Timex.Types.datetime()) :: calendar()
  def build_month(current_date) do
    start_date = Timex.beginning_of_month(current_date)
    end_date = Timex.end_of_month(current_date)

    start_date
    |> build_month(end_date, [])
    |> pad_start()
    |> pad_end()
    |> Enum.chunk_every(@days_in_week)
  end

  defp build_month(%{month: month} = current_date, %{month: month} = end_date, days) do
    days = days ++ [current_date]

    build_month(Timex.shift(current_date, days: 1), end_date, days)
  end

  defp build_month(_, _, days), do: days

  defp pad_start([start | _] = month) do
    weekday = next_weekday(Timex.weekday(start))

    if weekday > 1 do
      range = 1..(weekday - 1)
      pad = Enum.map(range, fn day -> Timex.shift(start, days: -(weekday - day)) end)
      pad ++ month
    else
      month
    end
  end

  defp pad_end(month) do
    end_date = List.last(month)
    weekday = Timex.weekday(end_date) + 1
    diff = @days_in_week - weekday

    if diff > 0 do
      range = 1..diff
      pad = Enum.map(range, fn day -> Timex.shift(end_date, days: day) end)
      month ++ pad
    else
      month
    end
  end

  defp next_weekday(7), do: 1
  defp next_weekday(n), do: n + 1
end
