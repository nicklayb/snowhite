defmodule Snowhite.Modules.Weather.Forecast do
  use Snowhite.Builder.Module, config_key: :weather, topic: "snowhite:modules:weather"
  alias OpenWeather.Weather.WeatherItem
  alias Snowhite.Modules.Weather

  def mount(socket) do
    socket = update(socket)

    {:ok, socket}
  end

  def render(assigns) do
    case get_option(assigns, :display) do
      :inline -> render_inline(assigns)
      :topdown -> render_topdown(assigns)
    end
  end

  defp render_topdown(assigns) do
    units = get_option(assigns, :units)
    locale = get_option(assigns, :locale)

    ~H"""
      <table class="forecasts topdown">
        <tbody>
        <%= for %{dt: dt, main: main, weather: [weather | _]} <- @forecasts do %>
          <tr>
            <td><img src={WeatherItem.icon_url(weather, "")}></td>
            <td><h2 class={"temperature " <>  to_string(units)}><%= round(main.temp) %></h2></td>
            <td><h3><%= day_name(dt, locale) %></h3></td>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end

  defp render_inline(assigns) do
    units = get_option(assigns, :units)
    locale = get_option(assigns, :locale)

    ~H"""
      <div class="forecasts inline">
        <%= for %{dt: dt, main: main, weather: [weather | _]} <- @forecasts do %>
          <div class="forecast-item">
            <div><img src={WeatherItem.icon_url(weather, "")}></div>
            <div><h2 class={"temperature " <> to_string(units)}><%= round(main.temp) %></h2></div>
            <div><h3><%= String.at(day_name(dt, locale), 0) %></h3></div>
          </div>
        <% end %>
    </div>
    """
  end

  defp day_name(date, locale) do
    Timex.lformat!(date, "{WDfull}", locale)
  end

  def handle_info(:updated, socket) do
    {:noreply, update(socket)}
  end

  def update(socket) do
    forecasts = Weather.Server.forecasts()
    forecasts = Enum.filter(forecasts, fn forecast -> forecast.dt.hour == 12 end)
    assign(socket, :forecasts, forecasts)
  end

  def module_options do
    Map.put(Snowhite.Modules.Weather.module_options(), :display, {:optional, :topdown})
  end

  defdelegate applications(options), to: Snowhite.Modules.Weather
end
