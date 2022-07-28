Logger.configure(level: :debug)

Application.put_env(:snowhite, SnowhiteDemo.Endpoint,
  http: [port: System.get_env("PORT")],
  url: [host: "localhost"],
  secret_key_base: "yUmFd0e4z0JqSMo1h3RWhj6Irb59jLVMrX1cCmL7oZey7BuHGLhx38IeVn5HVxLQ",
  render_errors: [view: SnowhiteDemo.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Snowhite.PubSub,
  live_view: [signing_salt: "FYVXIe3l111E7omIU9FCrsaQWGM5KbQQ"],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
    sass: {
      DartSass,
      :install_and_run,
      [:default, ~w(--embed-source-map --source-map-urls=absolute --watch)]
    },
    npx: [
      "cpx",
      "./static/**/*",
      "../priv/static",
      "-v",
      "--watch",
      cd: Path.expand("./assets", __DIR__)
    ]
  ],
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/snowhite_web/(live|views)/.*(ex)$",
      ~r"lib/snowhite_web/templates/.*(eex)$",
      ~r"lib/snowhite.ex"
    ]
  ]
)

Application.put_env(:esbuild, :version, "0.14.0")

Application.put_env(:esbuild, :default,
  args: ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/js),
  cd: Path.expand("./assets", __DIR__),
  env: %{"NODE_PATH" => Path.expand("./deps", __DIR__)}
)

Application.put_env(:dart_sass, :version, "1.49.11")

Application.put_env(:dart_sass, :default,
  args: ~w(css/app.scss ../priv/static/css/app.css),
  cd: Path.expand("./assets", __DIR__)
)

defmodule Snowhite.Profiles.Default do
  use Snowhite.Builder.Profile

  configure(
    locale: "en",
    city_id: "6167865",
    units: :metric,
    timezone: "America/Toronto"
  )

  modules(
    top_left: [
      Snowhite.Modules.Clock,
      Snowhite.Modules.Calendar,
      {Snowhite.Modules.StockMarket, symbols: ["PENN", "MSFT", "VCN.TSX"]},
      {Snowhite.Modules.News,
       feeds: [
         {"L'Hebdo", "https://www.lhebdojournal.com/feed/rss2/"},
         {"RC", "https://ici.radio-canada.ca/rss/4159"},
         {"La Presse; Justice et faits divers",
          "https://www.lapresse.ca/actualites/justice-et-faits-divers/rss"}
       ],
       persist_app: :snowhite}
    ],
    top_right: [
      {Snowhite.Modules.Weather.Current, refresh: ~d(4h)},
      {Snowhite.Modules.Weather.Forecast, refresh: ~d(4h), display: :inline},
      {Snowhite.Modules.Suntime, latitude: 43.653225, longitude: -79.383186}
    ]
  )
end

defmodule Snowhite.Profiles.Simple do
  use Snowhite.Builder.Profile

  configure(
    locale: "en",
    city_id: "6167865",
    units: :metric,
    timezone: "America/Toronto"
  )

  modules(
    top_left: [
      Snowhite.Modules.Clock,
      Snowhite.Modules.Calendar
    ]
  )
end

defmodule SnowhiteApp do
  use Snowhite, timezone: "America/Toronto"

  profile(:default, Snowhite.Profiles.Default)
  profile(:simple, Snowhite.Profiles.Simple)
end

defmodule SnowhiteDemo.Router do
  use Phoenix.Router
  import Snowhite, only: [snowhite_router: 1]

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipe_through(:browser)

  snowhite_router(SnowhiteApp)
end

defmodule SnowhiteDemo.Endpoint do
  use Phoenix.Endpoint, otp_app: :snowhite

  socket "/live", Phoenix.LiveView.Socket
  socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket

  plug Phoenix.LiveReloader
  plug Phoenix.CodeReloader

  plug Plug.Static,
    at: "/",
    from: :snowhite,
    gzip: false,
    only: ~w(css js)

  plug Plug.Session,
    store: :cookie,
    key: "_live_view_key",
    signing_salt: "bJ7Yf3Do"

  plug Plug.RequestId
  plug SnowhiteDemo.Router
end

Application.put_env(:phoenix, :serve_endpoints, true)
Application.put_env(:phoenix, :json_library, Jason)
Application.put_env(:bitly, :access_token, System.get_env("BITLY_TOKEN"))
Application.put_env(:snowhite, Finnhub, api_key: System.get_env("FINNHUB_API_KEY"))

Task.start(fn ->
  children = [
    {Phoenix.PubSub, [name: SnowhiteDemo.PubSub, adapter: Phoenix.PubSub.PG2]},
    SnowhiteDemo.Endpoint,
    SnowhiteApp.ApplicationSupervisor
  ]

  {:ok, _} = Supervisor.start_link(children, strategy: :one_for_one)
  Process.sleep(:infinity)
end)
