defmodule Snowhite.Modules.Clock do
  use Phoenix.LiveView

  def mount(_, %{"options" => options}, socket) do
    socket =
      socket
      |> assign(:options, options)
      |> set_current_date()

    refresh()
    {:ok, socket}
  end

  def render(%{options: options} = assigns) do
    text_align =
      options
      |> Keyword.get(:_position)
      |> to_string()
      |> text_align()

    time_format = Keyword.get(options, :time_format, "{h24}:{m}:{s}")
    date_format = Keyword.get(options, :date_format, "{WDfull} {D} {Mshort}")

    locale = Keyword.get(options, :locale, "en")

    ~L"""
      <div class="<%= text_align %>">
        <h1><%= Timex.lformat!(@current_date, time_format, locale) %></h1>
        <h2><%= Timex.lformat!(@current_date, date_format, locale) %></h2>
      </div>
    """
  end

  def handle_info(:update, socket) do
    refresh()
    {:noreply, set_current_date(socket)}
  end

  defp refresh do
    Process.send_after(self(), :update, 1000)
  end

  defp set_current_date(socket) do
    assign(socket, :current_date, now(socket.assigns))
  end

  defp text_align(position) do
    [_, align] = String.split(position, "_")

    "text-align-#{align}"
  end

  defp now(%{options: options}) do
    options
    |> Keyword.get(:timezone, "UTC")
    |> Timex.now()
  end
end
