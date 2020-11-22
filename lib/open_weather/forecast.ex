defmodule OpenWeather.Forecast do
  @keys ~w(city list)a
  defstruct @keys
  use Starchoice.Decoder

  defdecoder do
    field(:city, with: OpenWeather.Forecast.City)
    field(:list, with: OpenWeather.Forecast.ForecastItem)
  end
end
