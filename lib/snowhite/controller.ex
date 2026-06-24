defmodule Snowhite.Controller do
  use Phoenix.Controller, namespace: SnowhiteWeb

  import Plug.Conn
  alias SnowhiteWeb.Plug.PutProfile

  plug(:put_profile)
  plug(:put_view, SnowhiteWeb.Profile.View)
  plug(:put_root_layout, {SnowhiteWeb.LayoutView, :root})
  plug(:put_layout, {SnowhiteWeb.Layouts.View, :app})
  plug(:put_root_layout, {SnowhiteWeb.Layouts.View, :root})

  def put_profile(conn, _opts) do
    profiles =
      Map.new(Snowhite.Profile.Provider.profiles(), fn {profile_name, _} ->
        {profile_name, Snowhite.Profile.Server.layout(profile_name)}
      end)

    PutProfile.call(conn, PutProfile.init(profiles: profiles))
  end

  def index(%Plug.Conn{assigns: %{profile: profile}} = conn, params)
      when not is_nil(profile) do
    conn
    |> render("index.html", params: params, profile: profile)
  end

  defmacro __using__(_) do
    quote do
      get("/", Snowhite.Controller, :index)
    end
  end
end
