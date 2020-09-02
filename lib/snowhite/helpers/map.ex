defmodule Snowhite.Helpers.Map do
  @doc """
  Appends to a list in a map.

  iex> append(%{}, :numbers, 1)
  %{numbers: [1]}

  iex> append(%{numbers: [1]}, :numbers, 2)
  %{numbers: [1, 2]}
  """
  @spec append(map, atom(), any) :: map
  def append(map, key, item) do
    current = Map.get(map, key, [])

    Map.put(map, key, current ++ [item])
  end
end
