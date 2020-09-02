defmodule Snowhite.Modules.Forecast do
  use Snowhite.Builder.Module, config_key: :weather
  alias OpenWeather.Weather.WeatherItem
  @fallback_units :metric
  @fallback_locale "fr"

  every(:refresh, :refresh, &refresh/1)

  def mount(socket) do
    socket =
      socket
      |> assign(:forecasts, [])

    {:ok, socket}
  end

  def render(assigns) do
    units = get_option(assigns, :units, @fallback_units)
    locale = get_option(assigns, :locale, @fallback_locale)

    ~L"""
      <ul class="forecasts">
        <%= for %{dt: dt, main: main, weather: [weather | _]} <- @forecasts do %>
          <li>
            <img src="<%= WeatherItem.icon_url(weather, "") %>">
            <h2 class="temperature <%= units %>"><%= round(main.temp) %></h1>
            <h3><%= day_name(dt, locale) %></h3>
          </li>
        <% end %>
      </ul>
    """
  end

  defp day_name(date, locale) do
    Timex.lformat!(date, "{WDfull}", locale)
  end

  def refresh(socket) do
    with {:ok, response} <- call_weather_forecasts(socket) do
      forecasts = Enum.filter(response.list, fn forecast -> forecast.dt.hour == 12 end)
      assign(socket, :forecasts, forecasts)
    else
      _ -> socket
    end
  end

  def call_weather_forecasts(socket) do
    units = get_option(socket, :units, @fallback_units)
    locale = get_option(socket, :locale, nil)
    city_id = get_option(socket, :city_id, nil)

    OpenWeather.forecast(config(:api_key), %{
      id: city_id,
      lang: locale,
      units: units
    })
  end
end
