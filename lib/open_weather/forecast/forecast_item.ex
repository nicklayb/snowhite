defmodule OpenWeather.Forecast.ForecastItem do
  @keys ~w(dt main weather)a
  defstruct @keys
  use Starchoice.Decoder

  defdecoder do
    field(:dt, with: &Timex.from_unix/1)
    field(:main, with: OpenWeather.Weather.Main)
    field(:weather, with: OpenWeather.Weather.WeatherItem)
  end
end
