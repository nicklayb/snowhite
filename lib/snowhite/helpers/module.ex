defmodule Snowhite.Helpers.Module do
  @doc """
  Gets the parent module of a given module used by dot notation

  ## Examples
  ```
  iex> Snowhite.Helpers.Module.parent_module(Snowhite.Helpers.Module)
  Snowhite.Helpers
  ```
  """
  @spec parent_module(module()) :: module() | nil
  def parent_module(module) do
    if String.contains?(inspect(module), ".") do
      module
      |> to_string()
      |> String.split(".")
      |> Enum.reverse()
      |> tl()
      |> Enum.reverse()
      |> Enum.join(".")
      |> String.to_existing_atom()
    else
      nil
    end
  end
end
