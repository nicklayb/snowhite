defmodule SnowhiteWeb.Home.View do
  use SnowhiteWeb, {:view, path: "home/templates"}

  def modules, do: Snowhite.Module.modules()
end
