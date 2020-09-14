defmodule SnowhiteWeb.Profile.View do
  @moduledoc """
  Handles view logic of the rendered page for a given Profile.
  """
  use SnowhiteWeb, {:view, path: "profile/templates"}
  alias Snowhite.Builder.Layout
  alias Snowhite.Helpers.Casing

  @doc """
  Converts a layout to a keyword list representation so it can be enumerable.
  """
  @spec layout(Layout.t()) :: [{Layout.position(), [Layout.module_definition()]}]
  def layout(layout) do
    Layout.positions()
    |> Enum.map(&{&1, Map.get(layout, &1, [])})
  end

  @doc """
  Gets pane's HTML classes based on it's position identifier. It sets the "pane" class along with it's horizontal and vertical identifiers. For instance, `top_left` pane would have `class="pane top left"`.
  """
  @spec pane_class(Layout.position()) :: String.t()
  def pane_class(position) do
    [row, col] =
      position
      |> to_string()
      |> String.split("_", parts: 2)

    Enum.join(["pane", row, col], " ")
  end
end
