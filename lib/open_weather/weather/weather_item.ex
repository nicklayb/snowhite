defmodule OpenWeather.Weather.WeatherItem do
  @keys ~w(id main description icon)a
  defstruct @keys

  alias OpenWeather.Weather.WeatherItem
  use Snowhite.Helpers.Decoder, @keys

  def icon_url(%WeatherItem{icon: icon}, size \\ "@2x") do
    "https://openweathermap.org/img/wn/#{icon}#{size}.png"
  end
end
