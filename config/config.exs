import Config

config :snowhite, :modules,
  weather: [
    api_key: System.get_env("OPEN_WEATHER_API_KEY")
  ]

if Mix.env() == :dev do
  esbuild = fn args ->
    [
      args: ~w(./js/snowhite --bundle) ++ args,
      cd: Path.expand("../assets", __DIR__),
      env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
    ]
  end

  config :esbuild,
    version: "0.14.0",
    module: esbuild.(~w(--format=esm --sourcemap --outfile=../priv/js/snowhite.mjs)),
    main: esbuild.(~w(--format=cjs --sourcemap --outfile=../priv/js/snowhite.cjs.js)),
    cdn:
      esbuild.(
        ~w(--target=es2016 --format=iife --global-name=Snowhite --outfile=../priv/js/snowhite.js)
      )
end
