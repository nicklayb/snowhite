defmodule Snowhite.Modules.Weather.Forecast do
  use Snowhite.Builder.Module, config_key: :weather
  alias OpenWeather.Weather.WeatherItem
  alias Snowhite.Modules.Weather

  def mount(socket) do
    socket = update(socket)

    {:ok, socket}
  end

  def render(assigns) do
    units = get_option(assigns, :units)
    locale = get_option(assigns, :locale)

    ~L"""
      <table class="forecasts">
        <tbody>
        <%= for %{dt: dt, main: main, weather: [weather | _]} <- @forecasts do %>
          <tr>
            <td><img src="<%= WeatherItem.icon_url(weather, "") %>"></td>
            <td><h2 class="temperature <%= units %>"><%= round(main.temp) %></h1></td>
            <td><h3><%= day_name(dt, locale) %></h3></td>
          </tr>
        <% end %>
      </tbody>
    </table>
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

  defdelegate applications(options), to: Snowhite.Modules.Weather
  defdelegate module_options(), to: Snowhite.Modules.Weather
end
