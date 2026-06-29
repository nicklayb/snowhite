defmodule Snowhite.Modules.Suntime.Server do
  @moduledoc """
  Provide current days sunset and next day's sunrise.

  Is updated every morning at 1am through scheduler
  """
  use Snowhite.StateServer, pubsub_topic: "snowhite:modules:suntime"
  require Logger
  alias Snowhite.StateServer.Configuration

  @impl Snowhite.StateServer
  def init_configuration(_options) do
    %Configuration{update_timer: {:schedule, {:at, ~T[00:05:00]}}}
  end

  @impl Snowhite.StateServer
  def init_state(options) do
    state = options_to_state(%{days: []}, Snowhite.Modules.Suntime, options)

    {:ok, state}
  end

  @impl Snowhite.StateServer
  def handle_update(state, _configuration) do
    days = call_api(state)
    {:ok, %{state | days: days}}
  end

  @impl Snowhite.StateServer
  def handle_state_call(%{days: days}, _configuration) do
    days
  end

  @days 2
  @range 0..(@days - 1)
  defp call_api(%{timezone: timezone} = state) do
    date = Timex.now(timezone)

    Enum.map(@range, fn modifier ->
      date = Timex.shift(date, days: modifier)

      state
      |> call_for_date(date)
      |> Map.put(:date, date)
    end)
  end

  defp call_for_date(%{latitude: lat, longitude: lng, timezone: timezone}, date) do
    case Snowhite.Client.SunriseSunset.get({lng, lat}, date) do
      {:ok, results} ->
        map_results(results, timezone)

      _ ->
        %{sunrise: nil, sunset: nil}
    end
  end

  defp map_results(%{sunrise: sunrise, sunset: sunset}, timezone) do
    %{sunrise: sunrise, sunset: sunset}
    |> Enum.map(&as_timezoned_time(&1, timezone))
    |> Enum.into(%{})
  end

  defp as_timezoned_time({name, value}, timezone) do
    value =
      value
      |> Timex.to_datetime(timezone)
      |> DateTime.to_time()

    {name, value}
  end
end
