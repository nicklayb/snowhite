# Suntime

The Suntime module uses the [Sunrise-Sunset](https://sunrise-sunset.org/api) api to fetch current and next day's sunset and sunrise time.

Icons have been get from [The Noun Project](https://thenounproject.com) from [Yelena Polyakov](https://thenounproject.com/Yelena)

## Server

The server is scheduled to be updated a 1am every day to get current and next days's info.

## Options

- `longitude`: (`float`, required) Your longitude
- `latitude`: (`float`, required) Your latitude
- `timezone`: (`string`, optional) Your timezone, fallbacks to `UTC`
- `locale`: (`string`, optional) Locale to displays days of the forecast; fallbacks to `en`
