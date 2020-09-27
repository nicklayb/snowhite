defmodule Snowhite.Helpers.TaskRunnerTest do
  use Snowhite.TestCase

  alias Snowhite.Helpers.TaskRunner

  describe "run/1" do
    test "should run without params" do
      tasks = %{
        first: fn -> sleep_and_return(500) end,
        second: fn -> sleep_and_return(1000) end
      }

      assert %{first: {:ok, 500}, second: {:ok, 1000}} = TaskRunner.run(tasks)
    end

    test "should run with params" do
      tasks = [
        {:first, &sleep_and_return/1, [500]},
        {:second, &sleep_and_return/1, [1000]}
      ]

      assert [first: {:ok, 500}, second: {:ok, 1000}] = TaskRunner.run(tasks)
    end

    test "keeps input tasks format" do
      assert %{first: :ok} = TaskRunner.run(%{first: fn -> :ok end})
      assert [first: :ok] = TaskRunner.run(first: fn -> :ok end)
    end

    test "should run without params and applies the giver map_after/1" do
      tasks = %{
        first: fn -> sleep_and_return(500) end,
        second: fn -> sleep_and_return(1000) end
      }

      map_after = fn {:ok, v} -> to_string(v) end

      assert %{first: "500", second: "1000"} = TaskRunner.run(tasks, map_after)
    end
  end

  def sleep_and_return(ms) do
    :timer.sleep(ms)
    {:ok, ms}
  end
end
