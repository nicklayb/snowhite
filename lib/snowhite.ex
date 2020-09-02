defmodule Snowhite do
  use Snowhite.Builder

  @city_id "6145489"
  @timezone "America/Toronto"
  @locale "fr"
  @units :metric

  register_module(:top_left, Snowhite.Modules.Clock, timezone: @timezone, locale: @locale)

  register_module(:top_right, Snowhite.Modules.Weather,
    city_id: @city_id,
    locale: @locale,
    units: @units,
    refresh: ~d(4h)
  )

  register_module(:top_right, Snowhite.Modules.Forecast,
    city_id: @city_id,
    locale: @locale,
    units: @units,
    refresh: ~d(4h)
  )
end
