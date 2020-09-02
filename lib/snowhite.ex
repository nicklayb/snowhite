defmodule Snowhite do
  use Snowhite.Builder

  register_module(:top_right, Snowhite.Modules.Clock, timezone: "America/Toronto", locale: "fr")
end
