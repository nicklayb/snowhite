defmodule OpenWeather.Coord do
  @keys ~w(lat lng)a
  defstruct @keys
  use Starchoice.Decoder

  defdecoder do
    Enum.map(@keys, &field/1)
  end
end
