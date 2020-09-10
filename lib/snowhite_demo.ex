defmodule SnowhiteDemo do
  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def view(options \\ []) do
    path = Keyword.fetch!(options, :path)

    quote do
      use Phoenix.View,
        root: "lib/snowhite_demo",
        path: unquote(path),
        namespace: SnowhiteDemo

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

      # Include shared imports and aliases for views
      unquote(view_helpers())
    end
  end

  defp view_helpers do
    quote do
      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      # Import LiveView helpers (live_render, live_component, live_patch, etc)
      import Phoenix.LiveView.Helpers

      # Import basic rendering functionality (render, render_layout, etc)
      import Phoenix.View

      import SnowhiteDemo.ErrorHelpers
      import SnowhiteDemo.Gettext
      alias SnowhiteDemo.Router.Helpers, as: Routes
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  defmacro __using__({which, options}) when is_atom(which) and is_list(options) do
    apply(__MODULE__, which, [options])
  end
end
