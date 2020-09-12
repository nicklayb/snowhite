defmodule Snowhite.Helpers.Path do
  @doc """
  Gets the priv path for a given application. It can also support a list of folder to build the path

  ## Examples

  ```
  iex> priv_path(:snowhite, ["dets"])
  "/path/of/snowhite/priv
  ```
  """
  @spec priv_path(atom(), [String.t()]) :: String.t()
  def priv_path(app, path \\ []), do: Path.join([:code.priv_dir(app) | path])
end
