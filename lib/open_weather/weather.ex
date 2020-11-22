defmodule OpenWeather.Weather do
  @keys ~w(coord weather main id name)a
  defstruct @keys
  use Starchoice.Decoder

  defdecoder do
    field(:coord, with: OpenWeather.Coord)
    field(:weather, with: OpenWeather.Weather.WeatherItem)
    field(:main, with: OpenWeather.Weather.Main)
    field(:id)
    field(:name)
  end
end
