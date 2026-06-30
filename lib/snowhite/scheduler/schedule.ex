defmodule Snowhite.Scheduler.Schedule do
  alias __MODULE__
  defstruct name: nil, time: nil, message: nil, last_execution: nil, monitor_process: nil

  @type t :: %Schedule{
          name: schedule_id(),
          time: time_def(),
          message: message_def(),
          last_execution: NaiveDateTime.t() | nil,
          monitor_process: nil | pid()
        }
  @type schedule_id :: String.t() | atom()
  @type time_def :: {:at, Time.t()}
  @type message_def :: {pid(), any()}
  @spec new(schedule_id(), time_def(), message_def(), Keyword.t()) :: t()
  def new(name, time, message, options \\ []) do
    pid =
      with pid when is_pid(pid) <- Keyword.get(options, :monitor) do
        Process.monitor(pid)
        pid
      end

    %Schedule{name: name, time: time, message: message, monitor_process: pid}
  end

  @spec should_run?(t(), Time.t()) :: boolean()
  def should_run?(%Schedule{time: {:at, time}}, current_time),
    do: Time.diff(time, current_time) == 0

  def put_last_execution(%Schedule{} = schedule, date) do
    %Schedule{schedule | last_execution: date}
  end
end
