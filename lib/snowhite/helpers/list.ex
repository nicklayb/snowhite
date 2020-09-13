defmodule Snowhite.Helpers.List do
  @doc """
  Same as `cycle/2` excepts that is uses 1 as the count value
  ```
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
end
