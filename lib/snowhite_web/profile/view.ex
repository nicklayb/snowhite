defmodule SnowhiteWeb.Profile.View do
  use SnowhiteWeb, {:view, path: "profile/templates"}

  def layout(profile) do
    layout = profile.layout()

    Snowhite.Builder.Layout.positions()
    |> Enum.map(&{&1, Map.get(layout, &1, [])})
  end

  def pane_class(position) do
    [row, col] =
      position
      |> to_string()
      |> String.split("_", parts: 2)

    Enum.join(["pane", row, col], " ")
  end

  def module_class(module) do
    module
    |> to_string()
    |> String.replace("Elixir.", "")
    |> String.replace(".", "-")
    |> String.downcase()
  end
end
