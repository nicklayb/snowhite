defmodule Snowhite.Helpers.Module do
  @doc """
  Gets the parent module of a given module used by dot notation

  ## Examples
  ```
  iex> Snowhite.Helpers.Module.parent_module(Snowhite.Helpers.Module)
  Snowhite.Helpers
  ```
  """
  @spec parent_module(module()) :: module()
  defmacro parent_module(module) do
    quote do
      unquote(module)
      |> to_string()
      |> String.split(".")
      |> Enum.reverse()
      |> tl()
      |> Enum.reverse()
      |> Enum.join(".")
      |> String.to_existing_atom()
    end
  end
end
