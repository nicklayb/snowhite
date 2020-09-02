defmodule Snowhite do
  use Snowhite.Builder

  register_module(:top_right, Snowhite.Modules.Clock, timezone: "America/Toronto", locale: "fr")
  register_module(:top_left, Snowhite.Modules.Clock, timezone: "America/Toronto", locale: "fr")
end
