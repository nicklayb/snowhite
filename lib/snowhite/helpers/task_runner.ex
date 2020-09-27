defmodule Snowhite.Helpers.TaskRunner do
  @doc """
  Runs multiple tasks concurrently and returns once they all done.

  Following options are supported:

  - `map_after` (`function`, fallbacks to identity function): Runs the function on the await's result to map over the result of the task.

  ## Examples

  ```
  iex> alias Snowhite.Helpers.TaskRunner
  iex> TaskRunner.run([
    {:first, fn ->
      :timer.sleep(1000)
      {:done, 1000}
    end},
    {:first, fn ms ->
      :timer.sleep(ms)
      {:done, ms}
    end, [2000]}
  ])
  [{:first, {:done, 1000}}, {:second, {:done, 2000}}] # after 2000ms

  iex> map_after = fn v -> v / 1000 end
  iex> TaskRunner.run([
    {:first, fn ->
      :timer.sleep(1000)
      {:done, 1000}
    end},
    {:first, fn ms ->
      :timer.sleep(ms)
      {:done, ms}
    end, [2000]}
  ], map_after)
  [{:first, {:done, 1}}, {:second, {:done, 2}}] # after 2000ms
  ```
  """
  @type task_definition(key_type) :: {key_type, function()} | {key_type, function(), [any()]}
  @type option :: {:map_after, function()}
  @spec run([task_definition(any())], [option()]) :: [{any(), any()}]
  def run(tasks, options \\ []) do
    map_after = Keyword.get(options, :map_after, fn v -> v end)

    pids =
      Enum.map(tasks, fn
        {key, func} ->
          {key, Task.async(func)}

        {key, func, args} ->
          {key, Task.async(fn -> apply(func, args) end)}
      end)

    results =
      Enum.map(pids, fn {key, pid} ->
        {key, map_after.(Task.await(pid))}
      end)

    case tasks do
      %{} ->
        Enum.into(results, %{})

      _ ->
        results
    end
  end
end
