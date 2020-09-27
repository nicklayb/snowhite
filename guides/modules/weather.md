# Weather

The Weather module uses the OpenWeather API to show how's the weather where you live.

You **need** to provide an environment variable called `OPEN_WEATHER_API_KEY` with you OpenWeather's api key. This module has two submodules; current weather and forecasts. Both has their own feeds on OpenWeather.

Every hour, the data gets updated, this is to comply with OpenWeather's api call limitations and let's be honest, the weather rarely changes that much in an hour. But this is configurable, so you prefer, you can update the `refresh` option to something else than 1 hour.

## Current

The current weather uses the [`/weather`](https://openweathermap.org/current) endpoints which return info for the current weather based on the city id you set. Theres is [a list of city codes here to get yours](http://bulk.openweathermap.org/sample/)

## Forecast

The forecasts uses the [`/forecast`](https://openweathermap.org/forecast5) endpoint which provides about 5 days every 3 hours forecast. The view will pick the noon forecast to be displayed.

## Server

The server do both calls in parrallel then notifies the view. It keeps a custom casted struct of the OpenWeather's payload to be used in views.

## Options (common to both submodules)

- `city_id`: (`integer`, required) Your city's ID based on [this list](http://bulk.openweathermap.org/sample/)
- `locale`: (`string`, optional) Locale to displays days of the forecast; fallbacks to `en`
- `units`: (`unit`, optional) Unit to display weather info (either metric or imperial); fallbacks to `metric`
  - `unit`: `:metric | :imperial`
- `refresh`: (`integer`, optional) Numbers of milliseconds before refreshing the weather; fallbacks `~d(1h)`
