defmodule Finnhub.Quote do
  defstruct [
    :current_price,
    :change,
    :percent_change,
    :high_price,
    :low_price,
    :open_price,
    :previous_close_price,
    :timestamp
  ]

  use Starchoice.Decoder

  alias __MODULE__

  @type t :: %Quote{
          current_price: float(),
          change: float(),
          percent_change: float(),
          high_price: float(),
          low_price: float(),
          open_price: float(),
          previous_close_price: float(),
          timestamp: integer()
        }

  defdecoder do
    field(:current_price, source: "c")
    field(:change, source: "d")
    field(:percent_change, source: "dp")
    field(:high_price, source: "h")
    field(:low_price, source: "l")
    field(:open_price, source: "o")
    field(:previous_close_price, source: "pc")
    field(:timestamp, source: "t")
  end
end
