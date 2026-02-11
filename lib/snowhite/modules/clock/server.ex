defmodule Snowhite.Modules.Clock.Server do
  @moduledoc """
  Atomic clock server that syncs the time between clock modules.

  It ticks every seconds and updates itself
  """
  use Snowhite.StateServer, pubsub_topic: "snowhite:modules:clock"

  alias Snowhite.StateServer.Configuration
  @fallback_timezone "UTC"

  @impl Snowhite.StateServer
  def init_state(options) do
    {:ok, update(%{options: options, time: nil})}
  end

  @update_timer :timer.seconds(1)
  @impl Snowhite.StateServer
  def init_configuration(options) do
    %Configuration{update_timer: @update_timer, options: options}
  end

  @impl Snowhite.StateServer
  def handle_update(state, _configuration) do
    {:ok, update(state)}
  end

  @impl Snowhite.StateServer
  def handle_state_call(%{time: time}, _configuration) do
    %{time: time, date: Timex.to_date(time)}
  end

  def to_date(%{time: time}), do: Timex.to_date(time)

  defp update(%{options: options} = state) do
    time = now(options)

    %{state | time: time}
  end

  defp now(options) do
    options
    |> Keyword.get(:timezone, @fallback_timezone)
    |> Timex.now()
  end
end
