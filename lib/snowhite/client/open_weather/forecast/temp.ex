defmodule Snowhite.Client.OpenWeather.Forecast.Temp do
  @keys ~w(day min max night eve morn)a
  defstruct @keys
  use Starchoice.Decoder

  defdecoder do
    Enum.map(@keys, &field/1)
  end
end
