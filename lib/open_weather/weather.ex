defmodule OpenWeather.Weather do
  @keys ~w(coord weather main id name)a
  defstruct @keys

  alias OpenWeather.Weather.{Main, WeatherItem}

  use Snowhite.Helpers.Decoder, @keys

  def decode_field(:coord, %{"lat" => lat, "lon" => lon}), do: %{lat: lat, lon: lon}
  def decode_field(:weather, weathers), do: Enum.map(weathers, &WeatherItem.decode/1)
  def decode_field(:main, main), do: Main.decode(main)
  def decode_field(_, value), do: value
end
