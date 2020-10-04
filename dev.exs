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
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: "assets"
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

defmodule Snowhite.Profiles.Default do
  use Snowhite.Builder.Profile

  @timezone "America/Toronto"
  @city_id "6167865"
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

  register_module(:top_right, Snowhite.Modules.Suntime,
    timezone: @timezone,
    locale: @locale,
    latitude: 43.653225,
    longitude: -79.383186
  )

  register_module(:top_left, Snowhite.Modules.Rss,
    feeds: [
      {"L'Hebdo", "https://www.lhebdojournal.com/feed/rss2/"}
    ],
    persist_app: :snowhite
  )
end

defmodule SnowhiteApp do
  use Snowhite, timezone: "America/Toronto"

  profile(:default, Snowhite.Profiles.Default)
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

Task.start(fn ->
  children = [
    {Phoenix.PubSub, [name: SnowhiteDemo.PubSub, adapter: Phoenix.PubSub.PG2]},
    SnowhiteDemo.Endpoint,
    SnowhiteApp.ApplicationSupervisor
  ]

  {:ok, _} = Supervisor.start_link(children, strategy: :one_for_one)
  Process.sleep(:infinity)
end)
