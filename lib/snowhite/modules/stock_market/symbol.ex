defmodule Snowhite.Modules.StockMarket.Symbol do
  @moduledoc """
  Symbol for the stock market module. Adapters needs to convert payloads
  the the module below in order for them to be correctly displayed
  """
  defstruct [:symbol, :value, :change]

  alias __MODULE__

  @type t :: %Symbol{symbol: String.t(), value: float(), change: float()}
end
