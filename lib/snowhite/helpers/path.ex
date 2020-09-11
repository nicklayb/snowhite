defmodule Snowhite.Helpers.Path do
  def priv_path(app, path \\ []), do: Path.join([:code.priv_dir(app) | path])
end
