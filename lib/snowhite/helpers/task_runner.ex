defmodule Snowhite.Helpers.TaskRunner do
  def run(tasks) do
    pids =
      Enum.map(tasks, fn {key, func} ->
        {key, Task.async(func)}
      end)

    results =
      Enum.map(pids, fn {key, pid} ->
        {key, Task.await(pid)}
      end)

    case tasks do
      %{} ->
        Enum.into(results, %{})

      _ ->
        results
    end
  end
end
