defmodule SunriseSunset.Response do
  @keys ~w(
    sunrise
    sunset
    solar_noon
    day_length
    civil_twilight_begin
    civil_twilight_end
    nautical_twilight_begin
    nautical_twilight_end
    astronomical_twilight_begin
    astronomical_twilight_end
  )a
  defstruct @keys

  use Snowhite.Helpers.Decoder, @keys

  def decode_field(:day_length, value), do: value
  def decode_field(_, value), do: parse_utc_datetime(value)

  defp parse_utc_datetime(value) do
    Timex.parse!(value, "{RFC3339}")
  end
end
