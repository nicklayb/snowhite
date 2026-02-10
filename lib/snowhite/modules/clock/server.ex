defmodule Snowhite.Modules.Clock.Server do
  @moduledoc """
  Atomic clock server that syncs the time between clock modules.

  It ticks every seconds and updates itself
  """
  use GenServer
  import Snowhite.Helpers.Timing
  require Logger

  @auto_sync_timer ~d(1s)
  @fallback_timezone "UTC"

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def now do
    GenServer.call(__MODULE__, :now)
  end

  def date do
    __MODULE__
    |> GenServer.call(:now)
    |> Timex.to_date()
  end

  def init(options) do
    Logger.info("[#{inspect(__MODULE__)}] Started (#{inspect(options)})")
    Process.send_after(self(), :auto_sync, @auto_sync_timer)
    {:ok, update(%{options: options, time: nil})}
  end

  def handle_cast(:update, state) do
    send(self(), :notify)
    {:noreply, update(state)}
  end

  def handle_call(:now, _, %{time: time} = state) do
    {:reply, time, state}
  end

  def handle_info(:auto_sync, state) do
    state = update(state)
    Process.send_after(self(), :auto_sync, @auto_sync_timer)
    send(self(), :notify)
    {:noreply, state}
  end

  def handle_info(:notify, state) do
    Phoenix.PubSub.broadcast!(Snowhite.PubSub, "snowhite:modules:clock", :updated)
    {:noreply, state}
  end

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
