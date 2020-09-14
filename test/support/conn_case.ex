defmodule SnowhiteWeb.ConnCase do
  defmodule Router do
    use Phoenix.Router

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
  end

  defmodule Endpoint do
    use Phoenix.Endpoint, otp_app: :snowhite

    socket "/live", Phoenix.LiveView.Socket

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
    plug Router
  end

  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use SnowhiteWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import SnowhiteWeb.ConnCase

      # The default endpoint for testing
      @endpoint Endpoint
    end
  end

  setup _tags do
    conn = Phoenix.ConnTest.build_conn()
    conn = %Plug.Conn{conn | private: Map.put(conn.private, :phoenix_router, Router)}
    {:ok, conn: conn}
  end
end
