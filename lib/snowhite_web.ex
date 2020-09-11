defmodule SnowhiteWeb do
  def controller do
    quote do
      use Phoenix.Controller, namespace: SnowhiteWeb

      import Plug.Conn
    end
  end

  def view(options \\ []) do
    path = Keyword.fetch!(options, :path)

    quote do
      use Phoenix.View,
        root: "lib/snowhite_web",
        path: unquote(path),
        namespace: SnowhiteWeb

      unquote(view_helpers())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {SnowhiteWeb.Layouts.View, "live.html"}

      unquote(view_helpers())
    end
  end

  defp view_helpers do
    quote do
      use Phoenix.HTML
      import Phoenix.LiveView.Helpers
      import Phoenix.View
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  defmacro __using__({which, options}) when is_atom(which) and is_list(options) do
    apply(__MODULE__, which, [options])
  end
end
