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
    field(:current_price, source: "c", with: &Finnhub.Quote.enforce_float/1)
    field(:change, source: "d", with: &Finnhub.Quote.enforce_float/1)
    field(:percent_change, source: "dp", with: &Finnhub.Quote.enforce_float/1)
    field(:high_price, source: "h", with: &Finnhub.Quote.enforce_float/1)
    field(:low_price, source: "l", with: &Finnhub.Quote.enforce_float/1)
    field(:open_price, source: "o", with: &Finnhub.Quote.enforce_float/1)
    field(:previous_close_price, source: "pc", with: &Finnhub.Quote.enforce_float/1)
    field(:timestamp, source: "t")
  end

  def enforce_float(integer) when is_integer(integer), do: integer / 1
  def enforce_float(value), do: value
end
