defmodule Snowhite.Modules.StockMarket.Server do
  use Snowhite.StateServer, pubsub_topic: "snowhite:modules:stockmarket"
  alias Snowhite.StateServer.Configuration
  alias Snowhite.Modules.StockMarket

  @default_update_timer :timer.minutes(5)
  @impl Snowhite.StateServer
  def init_configuration(options) do
    update_timer = Keyword.get(options, :refresh, @default_update_timer)
    %Configuration{update_timer: update_timer}
  end

  @impl Snowhite.StateServer
  def init_state(options) do
    state =
      options_to_state(%{loaded: false, prices: %{}}, StockMarket, options)

    {:ok, state}
  end

  @impl Snowhite.StateServer
  def handle_state_call(%{prices: prices}, _configuration) do
    prices
  end

  @impl Snowhite.StateServer
  def handle_update(%{loaded: loaded} = state, _configuration) do
    if not loaded or market_open?(state) do
      async(state, :fetch_stocks, &update_prices/1)
      {:ok, %{state | loaded: true}}
    else
      :ignore
    end
  end

  @impl Snowhite.StateServer
  def handle_async(:fetch_stocks, _ref, prices, state, _configuration) do
    {:ok, %{state | prices: prices}}
  end

  defp update_prices(%{
         adapter: adapter,
         symbols: symbols,
         adapter_options: adapter_options,
         prices: prices
       }) do
    Enum.reduce(symbols, prices, fn symbol, acc ->
      case StockMarket.Adapter.invoke(adapter, symbol, adapter_options) do
        nil ->
          acc

        symbol_struct ->
          Map.put(acc, symbol, symbol_struct)
      end
    end)
  end

  defp market_open?(%{timezone: timezone}) do
    timezone
    |> Timex.now()
    |> market_open?()
  end

  defp market_open?(%DateTime{} = now) do
    business_day?(now) and after_opening_hour?(now) and before_closing_hour?(now)
  end

  defp after_opening_hour?(%{hour: hour}) when hour >= 9, do: true
  defp after_opening_hour?(_), do: true

  defp before_closing_hour?(%{hour: hour}) when hour < 17, do: true
  defp before_closing_hour?(_), do: false

  @business_days 1..5
  defp business_day?(date), do: Timex.weekday(date) in @business_days
end
