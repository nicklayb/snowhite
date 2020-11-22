defmodule OpenWeather.Weather.WeatherItem do
  @keys ~w(id main description icon)a
  defstruct @keys
  use Starchoice.Decoder
  alias __MODULE__

  defdecoder do
    Enum.map(@keys, &field/1)
  end

  def icon_url(%WeatherItem{icon: icon}, size \\ "@2x") do
    "https://openweathermap.org/img/wn/#{icon}#{size}.png"
  end
end
