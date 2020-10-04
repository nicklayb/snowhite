defmodule Snowhite.Scheduler do
  use GenServer

  alias Snowhite.Scheduler.Schedule
  import Snowhite.Helpers.Timing

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    tz = Keyword.get(opts, :timezone, "UTC")
    Process.send_after(self(), :tick, ~d(1s))
    {:ok, %{schedule: %{}, tz: tz}}
  end

  def schedule(name, time, message) do
    GenServer.cast(__MODULE__, {:schedule, name, {time, message}})
  end

  def unschedule(name) do
    GenServer.cast(__MODULE__, {:unschedule, name})
  end

  def handle_cast({:schedule, name, {time, message}}, %{schedule: schedule} = state) do
    schedule = Map.put(schedule, name, Schedule.new(name, time, message))
    state = %{state | schedule: schedule}
    {:noreply, state}
  end

  def handle_cast({:unschedule, name}, %{schedule: schedule} = state) do
    {:noreply, %{state | schedule: Map.delete(schedule, name)}}
  end

  def handle_info(:tick, state) do
    schedule = execute_scheduled(state)
    Process.send_after(self(), :tick, ~d(1s))
    {:noreply, %{state | schedule: schedule}}
  end

  defp execute_scheduled(%{schedule: schedule} = state) do
    now = now(state)
    time = NaiveDateTime.to_time(now)

    Enum.reduce(schedule, %{}, fn {name, item}, acc ->
      if Schedule.should_run?(item, time) do
        execute_scheduled(item)
        Map.put(acc, name, Schedule.put_last_execution(item, now))
      else
        Map.put(acc, name, item)
      end
    end)
  end

  defp execute_scheduled(%Schedule{message: {pid, message}}) do
    send(pid, message)
  end

  defp now(%{tz: tz}) do
    Timex.now(tz)
  end
end
