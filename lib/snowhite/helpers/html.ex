defmodule Snowhite.Helpers.Html do
  def classes(conditions, args) do
    conditions
    |> Enum.reduce([], fn {func, class}, acc ->
      if apply(func, args), do: [class | acc], else: acc
    end)
    |> Enum.join(" ")
  end
end
