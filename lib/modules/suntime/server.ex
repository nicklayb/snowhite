defmodule Snowhite.Modules.Suntime.Server do
  @moduledoc """
  Provide current days sunset and next day's sunrise.

  Is updated every morning at 1am through scheduler
  """
  use GenServer
  alias Snowhite.Scheduler
  require Logger

  @update_time {:at, ~T[01:00:00]}
  @fallback_timezone "UTC"

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def update do
    GenServer.cast(__MODULE__, :update)
  end

  def days do
    GenServer.call(__MODULE__, :days)
  end

  def init(options) do
    tz = Keyword.get(options, :timezone, @fallback_timezone)
    lat = Keyword.fetch!(options, :latitude)
    lng = Keyword.fetch!(options, :longitude)
    Logger.info("[#{__MODULE__}] Started (#{inspect(options)})")
    Scheduler.schedule(__MODULE__, @update_time, :update)
    send(self(), :update)
    {:ok, %{tz: tz, days: [], latitude: lat, longitude: lng}}
  end

  def handle_cast(:update, state) do
    send(self(), :update)
    {:noreply, state}
  end

  def handle_info(:update, state) do
    send(self(), :notify)
    days = call_api(state)
    {:noreply, %{state | days: days}}
  end

  def handle_info(:notify, state) do
    Phoenix.PubSub.broadcast!(Snowhite.PubSub, "snowhite:modules:suntime", :updated)
    {:noreply, state}
  end

  def handle_call(:days, _, %{days: days} = state) do
    {:reply, days, state}
  end

  @days 2
  @range 0..(@days - 1)
  defp call_api(%{tz: tz} = state) do
    date = Timex.now(tz)
    Enum.map(@range, fn modifier ->
      date = Timex.shift(date, days: modifier)

      state
      |> call_for_date(date)
      |> Map.put(:date, date)
    end)
  end

  defp call_for_date(%{latitude: lat, longitude: lng, tz: tz}, date) do
    case SunriseSunset.get({lng, lat}, date) do
      {:ok, results} ->
        map_results(results, tz)
      _ ->
        %{sunrise: nil, sunset: nil}
    end
  end

  defp map_results(%{sunrise: sunrise, sunset: sunset}, tz) do
    %{sunrise: sunrise, sunset: sunset}
    |> Enum.map(&as_timezoned_time(&1, tz))
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
