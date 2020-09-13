defmodule Snowhite.Helpers.Casing do
  @doc """
  Normalizes a module name. Elixir's module name includes a "Elixir." prefix which is removed here.

  ## Examples
  ```
  iex> normalize_module(Some.Module)
  "Some.Module"
  ```
  """
  def normalize_module(module) do
    module
    |> to_string()
    |> String.replace("Elixir.", "")
  end

  @doc """
  Converts a module name to a socket topic.

  ## Examples
  ```
  iex> topic(Some.Module)
  "some:module"
  ```
  """
  def topic(module) do
    module
    |> normalize_module()
    |> String.downcase()
    |> String.replace(".", ":")
  end

  @doc """
  Converts a module name to an HTML class.

  ## Examples
  ```
  iex> class(Some.Module)
  "some-module"
  ```
  """
  @spec class(any) :: binary
  def class(module) do
    module
    |> normalize_module()
    |> String.downcase()
    |> String.replace(".", "-")
  end

  @doc """
  Returns the configuration key of a module

  ## Examples
  ```
  iex> config_key(Snowhite.Modules.Clock)
  :clock
  iex> config_key(Snowhite.Modules.Weather.Forecast)
  :weather_forecast
  ```
  """
  def config_key(module) do
    module
    |> normalize_module()
    |> String.replace("Snowhite.Modules.", "")
    |> String.replace(".", "_")
    |> String.downcase()
    |> String.to_atom()
  end
end
