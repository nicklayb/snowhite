defmodule Snowhite.Modules.StockMarket.Adapters.Finnhub do
  @behaviour Snowhite.Modules.StockMarket.Adapter

  alias Snowhite.Modules.StockMarket.Symbol

  @impl Snowhite.Modules.StockMarket.Adapter
  def fetch_symbol(symbol, _options) do
    with {:ok, %Finnhub.Quote{current_price: current_price, change: change}} <-
           Finnhub.quote(symbol),
         false <- nil in [current_price, change] do
      %Symbol{symbol: symbol, value: current_price, change: change}
    else
      _ ->
        nil
    end
  end
end
