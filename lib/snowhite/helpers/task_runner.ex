defmodule Snowhite.Helpers.TaskRunner do
  @doc """
  Runs multiple tasks concurrently and returns once they all done.

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
  ```
  """
  @type task_definition(key_type) :: {key_type, function()}
  @spec run([task_definition(any())]) :: [{any(), any()}]
  def run(tasks) do
    pids =
      Enum.map(tasks, fn
        {key, func} ->
          {key, Task.async(func)}

        {key, func, args} ->
          {key, Task.async(fn -> apply(func, args) end)}
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
