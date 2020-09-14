defmodule Snowhite.Modules.Weather.Current do
  use Snowhite.Builder.Module, config_key: :weather, topic: "snowhite:modules:weather"

  alias Snowhite.Modules.Weather
  alias OpenWeather.Weather.WeatherItem

  @fallback_units :metric

  def mount(socket) do
    socket =
      socket
      |> assign(:temperature, 0)
      |> assign(:icon_url, "")
      |> assign(:name, "")
      |> update()

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

  def handle_info(:updated, socket) do
    {:noreply, update(socket)}
  end

  defp update(socket) do
    with %{name: name, weather: [weather | _], main: %{temp: temp}} <- Weather.Server.weather() do
      socket
      |> assign(:temperature, temp)
      |> assign(:icon_url, WeatherItem.icon_url(weather))
      |> assign(:name, name)
    else
      _ ->
        socket
    end
  end

  defdelegate applications(options), to: Snowhite.Modules.Weather
  defdelegate module_options(), to: Snowhite.Modules.Weather
end
