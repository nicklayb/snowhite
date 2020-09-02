defmodule OpenWeather.Forecast do
  @keys ~w(city list)a
  defstruct @keys

  alias OpenWeather.Forecast.{City, ForecastItem}
  use Snowhite.Helpers.Decoder, @keys

  def decode_field(_, nil), do: nil
  def decode_field(:city, city), do: City.decode(city)
  def decode_field(:list, list), do: Enum.map(list, &ForecastItem.decode/1)
  def decode_field(_, value), do: value
end
