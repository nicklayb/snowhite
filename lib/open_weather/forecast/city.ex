defmodule OpenWeather.Forecast.City do
  @keys ~w(name id)a
  defstruct @keys
  use Starchoice.Decoder

  defdecoder do
    Enum.map(@keys, &field/1)
  end
end
