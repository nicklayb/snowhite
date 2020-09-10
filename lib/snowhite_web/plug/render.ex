defmodule SnowhiteWeb.Plug.Render do
  @behaviour Plug
  import Plug.Conn
  import Phoenix.View

  def init(_opts) do
    %{}
  end

  def call(%Plug.Conn{assigns: %{profile: profile}} = conn, _options) when not is_nil(profile) do
    template = render(SnowhiteWeb.Profile.View, "index.html", conn: conn, profile: profile)

    send_resp(conn, 200, template)
  end

  def call(%Plug.Conn{} = conn, _options) do
    send_resp(conn, 404, "err")
  end
end
