defmodule Snowhite.Modules.Weather do
  use Snowhite.Builder.Module

  alias OpenWeather.Weather.WeatherItem

  @fallback_units :metric

  every(:refresh, :refresh, &refresh/1)

  def mount(socket) do
    socket =
      socket
      |> assign(:temperature, 0)
      |> assign(:icon_url, nil)
      |> assign(:name, "")

    {:ok, socket}
  end

  def render(assigns) do
    units = get_option(assigns, :units, @fallback_units)

    ~L"""
      <img src="<%= @icon_url %>">
      <div>
        <h1 class="temperature <%= units %>"><%= round(@temperature) %></h1>
        <h3><%= @name %></h3>
      </div>
    """
  end

  def refresh(socket) do
    with {:ok, %{name: name, weather: [weather | _], main: %{temp: temp}}} <- call_weather(socket) do
      socket
      |> assign(:temperature, temp)
      |> assign(:icon_url, WeatherItem.icon_url(weather))
      |> assign(:name, name)
    else
      _ -> socket
    end
  end

  def call_weather(socket) do
    units = get_option(socket, :units, @fallback_units)
    locale = get_option(socket, :locale, nil)
    city_id = get_option(socket, :city_id, nil)

    OpenWeather.current_weather(config(:api_key), %{
      id: city_id,
      lang: locale,
      units: units
    })
  end
end
