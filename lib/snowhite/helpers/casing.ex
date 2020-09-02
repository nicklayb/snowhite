defmodule Snowhite.Helpers.Casing do
  @doc """
  Normalizes a module name. Elixir's module name includes a "Elixir." prefix which is removed here.

  iex> normalize_module(Some.Module)
  "Some.Module"
  """
  def normalize_module(module) do
    module
    |> to_string()
    |> String.replace("Elixir.", "")
  end

  @doc """
  Converts a module name to a socket topic.

  iex> topic(Some.Module)
  "some:module"
  """
  def topic(module) do
    module
    |> normalize_module()
    |> String.downcase()
    |> String.replace(".", ":")
  end

  @doc """
  Converts a module name to an HTML class.

  iex> class(Some.Module)
  "some-module"
  """
  @spec class(any) :: binary
  def class(module) do
    module
    |> normalize_module()
    |> String.downcase()
    |> String.replace(".", "-")
  end

  def config_key(module) do
    module
    |> normalize_module()
    |> String.replace("Snowhite.Modules.", "")
    |> String.replace(".", "_")
    |> String.downcase()
    |> String.to_atom()
  end
end
