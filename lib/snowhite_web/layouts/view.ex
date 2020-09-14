defmodule SnowhiteWeb.Layouts.View do
  use SnowhiteWeb, {:view, path: "layouts/templates"}

  @doc """
  Gets the route helpers from the conn's router. As this view will be fired from another application and Snowhite doesn't include any endpoint nor default router. It fetches the router from the conn.
  """
  @spec route_helpers(Plug.Conn.t()) :: module()
  def route_helpers(%Plug.Conn{private: %{phoenix_router: router}}) do
    String.to_existing_atom("#{router}.Helpers")
  end
end
