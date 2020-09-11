import Config

config :snowhite, :modules,
  weather: [
    api_key: System.get_env("OPEN_WEATHER_API_KEY")
  ]
