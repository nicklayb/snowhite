defmodule OpenWeather.Weather.Main do
  @keys ~w(temp feels_like temp_min temp_max pressure humidity)a
  defstruct @keys

  use Snowhite.Helpers.Decoder, @keys
end
