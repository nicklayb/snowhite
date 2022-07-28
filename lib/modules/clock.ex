defmodule Snowhite.Modules.Clock do
  use Snowhite.Builder.Module
  import Snowhite.Builder.Module
  alias __MODULE__

  def mount(socket) do
    {:ok, set_current_date(socket)}
  end

  def module_options do
    %{
      locale: {:optional, "en"},
      timezone: {:optional, "UTC"},
      time_format: {:optional, "{h24}:{m}:{s}"},
      date_format: {:optional, "{WDfull} {D} {Mshort}"}
    }
  end

  def render(assigns) do
    time_format = get_option(assigns, :time_format)
    date_format = get_option(assigns, :date_format)

    locale = get_option(assigns, :locale)

    ~H"""
      <div>
        <h1><%= Timex.lformat!(@current_date, time_format, locale) %></h1>
        <h2><%= Timex.lformat!(@current_date, date_format, locale) %></h2>
      </div>
    """
  end

  def handle_info(:updated, socket) do
    {:noreply, set_current_date(socket)}
  end

  defp set_current_date(socket) do
    assign(socket, :current_date, Clock.Server.now())
  end

  def applications(options) do
    [
      {Clock.Server, options}
    ]
  end
end
