defmodule Snowhite.Helpers.Map do
  @spec append(map, atom(), any) :: map
  def append(map, key, item) do
    current = Map.get(map, key, [])

    Map.put(map, key, current ++ [item])
  end
end
