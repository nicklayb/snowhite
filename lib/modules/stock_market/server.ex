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
  def init(opts) do
    symbols = Keyword.fetch!(opts, :symbols)
    adapter = Keyword.fetch!(opts, :adapter)
    adapter_options = Keyword.get(opts, :adapter_options, [])

    send(self(), :sync)

    {:ok, %{prices: [], symbols: symbols, adapter: adapter, adapter_options: adapter_options}}
  end

  @impl GenServer
  def handle_info(:sync, state) do
    state = update_prices(state)
    Phoenix.PubSub.broadcast!(Snowhite.PubSub, "snowhite:modules:stockmarket", :updated)

    Process.send_after(self(), :sync, @sync_timer)

    {:noreply, state}
  end

  @impl GenServer
  def handle_call(:prices, _, %{prices: prices} = state) do
    {:reply, prices, state}
  end

  defp update_prices(
         %{adapter: adapter, symbols: symbols, adapter_options: adapter_options} = state
       ) do
    prices =
      Enum.reduce(symbols, [], fn symbol, acc ->
        case StockMarket.Adapter.invoke(adapter, symbol, adapter_options) do
          nil ->
            acc

          symbol ->
            [symbol | acc]
        end
      end)

    Map.put(state, :prices, prices)
  end
end
