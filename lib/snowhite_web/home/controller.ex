defmodule SnowhiteWeb.Home.Controller do
  use SnowhiteWeb, :controller

  plug(:put_view, SnowhiteWeb.Home.View)

  def index(conn, _params) do
    conn
    |> render("index.html")
  end
end
