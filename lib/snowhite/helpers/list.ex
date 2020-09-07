defmodule Snowhite.Helpers.List do
  def cycle(list), do: cycle(list, 1)

  def cycle([], _count), do: []

  def cycle(list, count) do
    range = 1..count

    Enum.reduce(range, list, fn _, [head | tail] -> tail ++ [head] end)
  end
end
