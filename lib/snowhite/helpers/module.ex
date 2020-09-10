defmodule Snowhite.Helpers.Module do
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
