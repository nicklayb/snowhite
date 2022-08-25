defmodule Snowhite.MixProject do
  use Mix.Project

  @github "https://github.com/nicklayb/snowhite"
  @description "Smart mirror framework"
  @version "2.1.2"
  def project do
    [
      app: :snowhite,
      version: @version,
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      source_url: @github,
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      docs: docs(),
      description: @description,
      package: package()
    ]
  end

  def package do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => @github
      },
      files: ["assets/css", "lib", "config", "priv", "mix.exs", "mix.lock"],
      maintainers: ["Nicolas Boisvert"]
    ]
  end

  def application do
    [
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.5.4"},
      {:phoenix_live_view, "~> 0.13"},
      {:floki, ">= 0.0.0", only: :test},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0", only: :dev},
      {:timex, "~> 3.6.2"},
      {:httpoison, "~> 1.7"},
      {:elixir_feed_parser, "~> 2.1.0"},
      {:sweet_xml, "~> 0.6.6"},
      {:eqrcode, "~> 0.1.7"},
      {:bitly, "~> 0.1"},
      {:starchoice, "~> 0.2.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:esbuild, "~> 0.2", runtime: Mix.env() == :dev},
      {:dart_sass, "~> 0.5", runtime: Mix.env() == :dev}
    ]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      extra_section: "GUIDES",
      groups_for_modules: groups_for_modules(),
      extras: extras(),
      groups_for_extras: groups_for_extras()
    ]
  end

  defp extras do
    [
      "guides/getting_started/introduction.md",
      "guides/modules/clock.md",
      "guides/modules/news.md",
      "guides/modules/stock_market.md",
      "guides/modules/weather.md",
      "guides/modules/suntime.md",
      "guides/changelog.md"
    ]
  end

  defp groups_for_extras do
    [
      "Getting started": ~r/guides\/getting_started\/.?/,
      Modules: ~r/guides\/modules\/.?/
    ]
  end

  defp groups_for_modules do
    [
      Modules: [
        Snowhite.Modules.Clock,
        Snowhite.Modules.Calendar,
        Snowhite.Helpers.CalendarBuilder,
        Snowhite.Modules.Weather,
        Snowhite.Modules.Weather.Current,
        Snowhite.Modules.Weather.Forecast,
        Snowhite.Modules.News,
        Snowhite.Modules.News.Poller,
        Snowhite.Modules.News.NewsItem,
        Snowhite.UrlShortener,
        Snowhite.Modules.Suntime,
        Snowhite.Modules.Suntime.Server,
        Snowhite.Modules.StockMarket,
        Snowhite.Modules.StockMarket.Server,
        Snowhite.Modules.StockMarket.Symbol,
        Snowhite.Modules.StockMarket.Adapter,
        Snowhite.Modules.StockMarket.Adapters.Finnhub
      ],
      Servers: [
        Snowhite.Modules.Clock.Server,
        Snowhite.Modules.News.Server,
        Snowhite.Modules.Weather.Server,
        Snowhite.Modules.Suntime.Server,
        Snowhite.Scheduler,
        Snowhite.Scheduler.Schedule
      ],
      Helpers: [
        Snowhite.Helpers.Casing,
        Snowhite.Helpers.Html,
        Snowhite.Helpers.List,
        Snowhite.Helpers.Map,
        Snowhite.Helpers.Module,
        Snowhite.Helpers.Path,
        Snowhite.Helpers.TaskRunner,
        Snowhite.Helpers.Timing
      ],
      Clients: [
        Finnhub,
        Finnhub.Quote,
        OpenWeather,
        OpenWeather.Coord,
        OpenWeather.Forecast,
        OpenWeather.Forecast.City,
        OpenWeather.Forecast.ForecastItem,
        OpenWeather.Forecast.Temp,
        OpenWeather.Weather,
        OpenWeather.Weather.Main,
        OpenWeather.Weather.WeatherItem,
        SunriseSunset,
        SunriseSunset.Response
      ],
      Builder: [
        Snowhite,
        Snowhite.Builder,
        Snowhite.Builder.Controller,
        Snowhite.Builder.Layout,
        Snowhite.Builder.Module,
        Snowhite.Builder.Profile,
        Snowhite.Builder.Supervisor
      ],
      Web: [
        SnowhiteWeb,
        SnowhiteWeb.Layouts.View,
        SnowhiteWeb.Plug.PutProfile,
        SnowhiteWeb.Profile.View
      ]
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "cmd npm install --prefix assets"],
      "assets.build": ["esbuild module", "esbuild cdn", "esbuild main"]
    ]
  end
end
