defmodule Snowhite.Modules.Clock do
  use Snowhite.Builder.Module
  import Snowhite.Builder.Module
  alias __MODULE__

  def mount(socket) do
    socket =
      socket
      |> assign(:current_date, nil)
      |> set_current_date()

    {:ok, socket}
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
    timezone = get_option(assigns, :timezone)

    ~H"""
      <div id={id(locale, timezone)} phx-hook="SnowhiteClock">
        <h1 class="time"><%= Timex.lformat!(@current_date, time_format, locale) %></h1>
        <h2><%= Timex.lformat!(@current_date, date_format, locale) %></h2>
      </div>
    """
  end

  defp id(locale, timezone), do: Enum.join([locale, timezone], "-")

  def handle_info(:updated, socket) do
    {:noreply, set_current_date(socket)}
  end

  defp set_current_date(%{assigns: assigns} = socket) do
    now = Clock.Server.now()

    if send_sync?(Map.get(assigns, :current_date, Timex.now()), now) do
      assign(socket, :current_date, now)
    else
      socket
    end
  end

  defp send_sync?(nil, _now), do: true

  defp send_sync?(assigned, now) do
    abs(Timex.diff(assigned, now, :hours)) >= 1
  end

  def applications(options) do
    [
      {Clock.Server, options}
    ]
  end
end
