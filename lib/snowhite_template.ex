defmodule Snowhite.Template do
  use Snowhite.Builder.Profile

  @city_id "6167865"
  @timezone "America/Toronto"
  @locale "en"
  @units :metric

  register_module(:top_left, Snowhite.Modules.Clock, timezone: @timezone, locale: @locale)

  register_module(:top_left, Snowhite.Modules.Calendar, timezone: @timezone, locale: @locale)

  register_module(:top_right, Snowhite.Modules.Weather.Current,
    city_id: @city_id,
    locale: @locale,
    units: @units,
    refresh: ~d(4h)
  )

  register_module(:top_right, Snowhite.Modules.Weather.Forecast,
    city_id: @city_id,
    locale: @locale,
    units: @units,
    refresh: ~d(4h)
  )

  register_module(:top_left, Snowhite.Modules.Rss,
    feeds: [
      {"Hacker News", "https://hnrss.org/newest"}
    ]
  )
end
