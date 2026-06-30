defmodule Snowhite.Scheduler do
  @moduledoc """
  The scheduler runs once in the system and is used to call process
  at specific times, this is mostly used for modules that has to update on
  a schedule rather than periodically. For instance, a module that updates
  every morning like `Suntime` will register a schedule at `00:05:00` daily.
  """
  use GenServer

  require Logger

  alias Snowhite.Scheduler.Schedule
  import Snowhite.Helpers.Timing

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenServer
  def init(opts) do
    timezone = Keyword.get(opts, :timezone, "UTC")

    Logger.info("[#{inspect(__MODULE__)}] Started")
    Process.send_after(self(), :tick, ~d(1s))
    {:ok, %{schedule: %{}, timezone: timezone}}
  end

  def schedule(name, time, message, options \\ []) do
    GenServer.cast(__MODULE__, {:schedule, name, {time, message}, options})
  end

  def unschedule(name) do
    GenServer.cast(__MODULE__, {:unschedule, name})
  end

  @impl GenServer
  def handle_cast({:schedule, name, {time, message}, options}, %{schedule: schedule} = state) do
    schedule = Map.put(schedule, name, Schedule.new(name, time, message, options))
    state = %{state | schedule: schedule}
    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:unschedule, name}, %{schedule: schedule} = state) do
    {:noreply, %{state | schedule: Map.delete(schedule, name)}}
  end

  @impl GenServer
  def handle_info(:tick, state) do
    schedule = execute_scheduled(state)
    Process.send_after(self(), :tick, ~d(1s))
    {:noreply, %{state | schedule: schedule}}
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    schedule =
      Enum.reduce(state.schedule, %{}, fn {name, %Schedule{monitor_process: process} = schedule},
                                          acc ->
        if process == pid do
          acc
        else
          Map.put(acc, name, schedule)
        end
      end)

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

  defp now(%{timezone: timezone}) do
    Timex.now(timezone)
  end
end
