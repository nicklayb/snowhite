defmodule Snowhite.Builder.Controller do
  defmacro build do
    quote do
      defmodule Controller do
        use Phoenix.Controller, namespace: SnowhiteWeb

        import Plug.Conn
        require Snowhite.Helpers.Module
        alias SnowhiteWeb.Plug.PutProfile
        @parent_module Snowhite.Helpers.Module.parent_module(__MODULE__)

        plug(:put_profile)
        plug(:put_view, SnowhiteWeb.Profile.View)
        plug(:put_root_layout, {SnowhiteWeb.LayoutView, :root})
        plug(:put_layout, {SnowhiteWeb.Layouts.View, :app})
        plug(:put_root_layout, {SnowhiteWeb.Layouts.View, :root})

        def put_profile(conn, _opts) do
          PutProfile.call(conn, PutProfile.init(profiles: @parent_module.profiles()))
        end

        def index(%Plug.Conn{assigns: %{profile: profile}} = conn, params)
            when not is_nil(profile) do
          conn
          |> render("index.html", params: params, profile: profile)
        end
      end
    end
  end
end
