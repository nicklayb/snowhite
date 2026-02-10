defmodule Snowhite.Modules.StockMarket.Adapter do
  alias Snowhite.Modules.StockMarket.Symbol

  @callback fetch_symbol(String.t(), Keyword.t()) :: Symbol.t() | nil

  def invoke(adapter, symbol, options) do
    apply(adapter, :fetch_symbol, [symbol, options])
  end
end
