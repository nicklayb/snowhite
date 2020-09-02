defmodule Snowhite.Modules.Clock do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    refresh()
    {:ok, update_time(socket)}
  end

  def render(assigns) do
    ~L"""
      <h1><%= @time %></h1>
    """
  end

  def handle_info(:update, socket) do
    refresh()
    {:noreply, update_time(socket)}
  end

  defp refresh do
    Process.send_after(self(), :update, 1000)
  end

  defp time do
    NaiveDateTime.utc_now()
    |> NaiveDateTime.to_time()
    |> to_string()
  end

  defp update_time(socket) do
    assign(socket, :time, time())
  end
end
