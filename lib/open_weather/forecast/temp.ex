defmodule OpenWeather.Forecast.Temp do
  @keys ~w(day min max night eve morn)a
  defstruct @keys

  use Snowhite.Helpers.Decoder, @keys
end
