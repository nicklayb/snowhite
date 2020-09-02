defmodule SnowhiteWeb.Home.Controller do
  use SnowhiteWeb, :controller

  plug(:put_view, SnowhiteWeb.Home.View)

  def index(conn, params) do
    conn
    |> render("index.html", params: params)
  end
end
