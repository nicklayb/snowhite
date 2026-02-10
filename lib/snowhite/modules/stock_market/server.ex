defmodule Snowhite.Modules.StockMarket.Server do
  use GenServer

  alias Snowhite.Modules.StockMarket

  @sync_timer :timer.minutes(5)

  def start_link(opts) do
    name =
      case Keyword.get(opts, :name, __MODULE__) do
        nil -> __MODULE__
        name -> name
      end

    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def prices(name \\ __MODULE__) do
    GenServer.call(name, :prices)
  end

  @impl GenServer
  def init(options) do
    send(self(), {:sync, true})

    {:ok, init_state(options)}
  end

  @impl GenServer
  def handle_info({:sync, force?}, state) do
    state =
      if force? or market_open?(state) do
        state = update_prices(state)
        Phoenix.PubSub.broadcast!(Snowhite.PubSub, "snowhite:modules:stockmarket", :updated)
        state
      else
        state
      end

    Process.send_after(self(), {:sync, false}, @sync_timer)

    {:noreply, state}
  end

  @impl GenServer
  def handle_call(:prices, _, %{prices: prices} = state) do
    {:reply, prices, state}
  end

  defp update_prices(
         %{adapter: adapter, symbols: symbols, adapter_options: adapter_options, prices: prices} =
           state
       ) do
    prices =
      Enum.reduce(symbols, prices, fn symbol, acc ->
        case StockMarket.Adapter.invoke(adapter, symbol, adapter_options) do
          nil ->
            acc

          symbol_struct ->
            Map.put(acc, symbol, symbol_struct)
        end
      end)

    Map.put(state, :prices, prices)
  end

  defp init_state(options) do
    symbols = Keyword.fetch!(options, :symbols)
    adapter = Keyword.fetch!(options, :adapter)
    timezone = Keyword.fetch!(options, :timezone)
    adapter_options = Keyword.get(options, :adapter_options, [])

    %{
      prices: %{},
      symbols: symbols,
      adapter: adapter,
      adapter_options: adapter_options,
      timezone: timezone
    }
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
