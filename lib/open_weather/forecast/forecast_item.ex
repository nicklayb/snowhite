defmodule OpenWeather.Forecast.ForecastItem do
  @keys ~w(dt main weather)a
  defstruct @keys

  alias OpenWeather.Weather.Main
  alias OpenWeather.Weather.WeatherItem
  use Snowhite.Helpers.Decoder, @keys

  def decode_field(:dt, date), do: Timex.from_unix(date)
  def decode_field(:main, main), do: Main.decode(main)
  def decode_field(:weather, weathers), do: Enum.map(weathers, &WeatherItem.decode/1)
end
