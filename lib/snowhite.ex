defmodule Snowhite do
  @moduledoc """
  This module is meant to be used to define profile set. This module generates some convenience modules.

  ### Controller
  Named `MySnowhite.Profiles.Controller`.

  To be able to route to the page, a profile set needs a Controller. The controller only have one function that renders the Snowhite's view

  ### Application supervisor
  Named `MySnowhite.Profiles.ApplicationSupervisor`.

  This supervisor is responsible for managing Servers that carries datas. If you use a modules that has a servers (most of them do), then you need this supervisor.

  It has to be supervised by your project's application so don't forget to register it.

  ```elixir
  defmodule MySnowhite.Application do
    use Application

    def start(_type, _args) do
      children = [
        {Phoenix.PubSub, name: MySnowhite.PubSub},
        MySnowhiteWeb.Endpoint,
        MySnowhite.Profiles.ApplicationSupervisor # <-- Here
      ]

      opts = [strategy: :one_for_one, name: MySnowhite.Supervisor]
      Supervisor.start_link(children, opts)
    end

    def config_change(changed, _new, removed) do
      MySnowhiteWeb.Endpoint.config_change(changed, removed)
      :ok
    end
  end
  ```
  """

  @doc """
  Imports required functions to build a Snowhite profile set.
  """
  @spec __using__(any()) :: Macro.t()
  defmacro __using__(_) do
    quote do
      @before_compile {Snowhite.Builder, :__before_compile__}
      require Snowhite.Builder.Supervisor
      require Snowhite.Builder.Controller
      import Snowhite.Builder
      @profiles %{}

      Snowhite.Builder.Supervisor.build()
      Snowhite.Builder.Controller.build()
    end
  end

  @doc """
  Declares router endpoint for a given profile set controller.

  If your application declares more profiles, each one of those needs to have their router defined by calling this function

  ## Examples

  ```elixir
  defmodule MyRouter do
    use Phoenix.Router

    import Plug.Conn
    import Phoenix.Controller
    import Snowhite, only: [snowhite_router: 1]

    pipeline :browser do
      plug :accepts, ["html"]
      plug :fetch_session
      plug :fetch_flash
      plug :protect_from_forgery
      plug :put_secure_browser_headers
    end

    pipe_through :browser

    snowhite_router(MySnowhite.Profiles)
  end
  ```
  """
  @spec snowhite_router(module()) :: Macro.t()
  defmacro snowhite_router(snowhite_app) do
    quote do
      get("/", unquote(snowhite_app).Controller, :index)
    end
  end
end
