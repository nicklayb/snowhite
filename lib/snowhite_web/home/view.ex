defmodule SnowhiteWeb.Home.View do
  use SnowhiteWeb, {:view, path: "home/templates"}

  def modules, do: Snowhite.modules()
end
