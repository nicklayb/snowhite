defmodule Snowhite.MixProject do
  use Mix.Project

  @github "https://github.com/nicklayb/snowhite"
  @description "Smart mirror framework"
  @version "0.1.0"
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
      {:phoenix_live_view, "~> 0.13.0"},
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
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "cmd npm install --prefix assets"]
    ]
  end
end
