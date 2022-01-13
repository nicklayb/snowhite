defmodule Snowhite.Helpers.List do
  @doc """
  Same as `cycle/2` excepts that is uses 1 as the count value
  """
  @spec cycle(list()) :: list()
  def cycle(list), do: cycle(list, 1)

  @doc """
  Cycles a list by a given number of items (default to 1).

  ## Examples
  ```
  iex> cycle([1, 2, 3, 4])
  [2, 3, 4, 1]
  iex> cycle([1, 2, 3, 4], 2)
  [3, 4, 1, 2]
  """
  @spec cycle(list(), non_neg_integer()) :: list()
  def cycle([], _count), do: []

  def cycle(list, count) do
    range = 1..count

    Enum.reduce(range, list, fn _, [head | tail] -> tail ++ [head] end)
  end

  @doc "Filters and maps a list with two different function"
  @spec filter_map(Enum.t(), (any() -> boolean()), (any() -> any())) :: [any()]
  def filter_map(items, filter_function, map_function) do
    items
    |> Enum.reduce([], fn item, acc ->
      if filter_function.(item) do
        [map_function.(item) | acc]
      else
        acc
      end
    end)
    |> Enum.reverse()
  end
end
