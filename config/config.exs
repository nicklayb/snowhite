import Config

config :snowhite, :modules,
  weather: [
    api_key: System.get_env("OPEN_WEATHER_API_KEY")
  ]

config :esbuild,
  version: "0.14.0",
  default: [
    args: ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/js),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :dart_sass,
  version: "1.49.11",
  default: [
    args: ~w(css/app.scss ../priv/static/css/app.css),
    cd: Path.expand("../assets", __DIR__)
  ]
