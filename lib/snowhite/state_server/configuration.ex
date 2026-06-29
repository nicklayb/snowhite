defmodule Snowhite.StateServer.Configuration do
  defstruct [:update_timer, options: %{}]

  alias Snowhite.StateServer.Configuration

  @type update_timer :: non_neg_integer() | {:schedule, Snowhite.Scheduler.Schedule.time_def()}

  @type t :: %Configuration{
          update_timer: update_timer(),
          options: map()
        }
end
