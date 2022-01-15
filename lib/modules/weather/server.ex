defmodule Snowhite.Modules.Weather.Server do
  use GenServer
  alias Snowhite.Helpers.TaskRunner
  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def update do
    GenServer.cast(__MODULE__, :update)
  end

  def weather do
    GenServer.call(__MODULE__, :weather)
  end

  def forecasts do
    GenServer.call(__MODULE__, :forecasts)
  end

  def init(options) do
    Logger.info("[#{inspect(__MODULE__)}] Started")
    update()
    Process.send_after(self(), :auto_sync, Keyword.fetch!(options, :refresh))
    {:ok, %{options: options, forecasts: [], weather: nil}}
  end

  def handle_cast(:update, state) do
    state = update(state)
    send(self(), :notify)
    {:noreply, state}
  end

  def handle_call(:weather, _, %{weather: weather} = state) do
    {:reply, weather, state}
  end

  def handle_call(:forecasts, _, %{forecasts: forecasts} = state) do
    {:reply, forecasts, state}
  end

  def handle_info(:auto_sync, %{options: options} = state) do
    state = update(state)
    send(self(), :notify)
    Process.send_after(self(), :auto_sync, Keyword.fetch!(options, :refresh))
    {:noreply, state}
  end

  def handle_info(:notify, state) do
    Phoenix.PubSub.broadcast!(Snowhite.PubSub, "snowhite:modules:weather", :updated)
    {:noreply, state}
  end

  defp update(%{options: options} = state) do
    params = options_to_params(options)
    api_key = Keyword.fetch!(options, :api_key)

    results =
      TaskRunner.run(%{
        weather: fn -> current_weather(api_key, params) end,
        forecasts: fn -> forecast(api_key, params) end
      })

    Map.merge(state, results)
  end

  defp current_weather(api_key, params) do
    case OpenWeather.current_weather(api_key, params) do
      {:ok, weather} -> weather
      _ -> nil
    end
  end

  defp forecast(api_key, params) do
    case OpenWeather.forecast(api_key, params) do
      {:ok, %{list: forecasts}} -> forecasts
      _ -> []
    end
  end

  defp options_to_params(options) do
    %{
      id: Keyword.fetch!(options, :city_id),
      lang: Keyword.fetch!(options, :locale),
      units: Keyword.fetch!(options, :units)
    }
  end
end
