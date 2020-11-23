defmodule SunriseSunset.Response do
  @dates ~w(
    sunrise
    sunset
    solar_noon
    civil_twilight_begin
    civil_twilight_end
    nautical_twilight_begin
    nautical_twilight_end
    astronomical_twilight_begin
    astronomical_twilight_end
  )a
  defstruct [:day_length] ++ @dates
  use Starchoice.Decoder

  defdecoder do
    field(:day_length)

    Enum.map(@dates, fn field_name ->
      field(field_name, with: &SunriseSunset.Response.parse_utc_datetime/1)
    end)
  end

  def parse_utc_datetime(value) do
    Timex.parse!(value, "{RFC3339}")
  end
end
