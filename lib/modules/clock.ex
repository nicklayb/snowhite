defmodule Snowhite.Modules.Clock do
  use Snowhite.Builder.Module
  import Snowhite.Builder.Module

  @fallback_time_format "{h24}:{m}:{s}"
  @fallback_date_format "{WDfull} {D} {Mshort}"
  @fallback_locale "en"
  @fallback_timezone "UTC"
  def mount(socket) do
    {:ok, set_current_date(socket)}
  end

  every(~d(1s), :tick, &set_current_date/1)

  def render(%{options: options} = assigns) do
    time_format = Keyword.get(options, :time_format, @fallback_time_format)
    date_format = Keyword.get(options, :date_format, @fallback_date_format)

    locale = Keyword.get(options, :locale, @fallback_locale)

    ~L"""
      <div>
        <h1><%= Timex.lformat!(@current_date, time_format, locale) %></h1>
        <h2><%= Timex.lformat!(@current_date, date_format, locale) %></h2>
      </div>
    """
  end

  defp set_current_date(socket) do
    assign(socket, :current_date, now(socket.assigns))
  end

  defp now(%{options: options}) do
    options
    |> Keyword.get(:timezone, @fallback_timezone)
    |> Timex.now()
  end
end
