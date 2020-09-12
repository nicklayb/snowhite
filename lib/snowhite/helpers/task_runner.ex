defmodule Snowhite.Helpers.TaskRunner do
  @doc """
  Runs multiple tasks concurrently and returns once they all done.

  ## Examples

  ```
  iex> alias Snowhite.Helpers.TaskRunner
  iex> TaskRunner.run([
    {:first, fn ->
      :timer.sleep(1000)
      :done_1000
    end},
    {:first, fn ->
      :timer.sleep(2000)
      :done_2000
    end}
  ])
  [{:first, :done_1000}, {:second, :done_2000}] # after 2000ms
  ```
  """
  @type task_definition(key_type) :: {key_type, function()}
  @spec run([task_definition(any())]) :: [{any(), any()}]
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
