defmodule OpenWeather.Forecast.City do
  @keys ~w(name id)a
  defstruct @keys

  use Snowhite.Helpers.Decoder, @keys
end
