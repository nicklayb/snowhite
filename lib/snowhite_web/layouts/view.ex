defmodule SnowhiteWeb.Layouts.View do
  use SnowhiteWeb, {:view, path: "layouts/templates"}

  def route_helpers(%{private: %{phoenix_router: router}}) do
    String.to_existing_atom("#{router}.Helpers")
  end
end
