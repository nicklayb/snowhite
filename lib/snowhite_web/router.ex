defmodule SnowhiteWeb.Router do
  use SnowhiteWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {SnowhiteWeb.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:put_layout, {SnowhiteWeb.Layouts.View, :app})
    plug(:put_root_layout, {SnowhiteWeb.Layouts.View, :root})
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", SnowhiteWeb do
    pipe_through(:browser)

    get("/", Home.Controller, :index)
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through(:browser)
      live_dashboard("/dashboard", metrics: SnowhiteWeb.Telemetry)
    end
  end
end
