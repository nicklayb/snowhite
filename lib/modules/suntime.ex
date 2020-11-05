defmodule Snowhite.Modules.Suntime do
  use Snowhite.Builder.Module
  import Snowhite.Builder.Module
  alias __MODULE__

  def mount(socket) do
    socket =
      socket
      |> assign(:days, [])

    send(self(), :updated)

    {:ok, socket}
  end

  def module_options do
    %{
      timezone: {:optional, "UTC"},
      locale: {:optional, "en"},
      longitude: :required,
      latitude: :required
    }
  end

  # Icon by Yelena Polyakov https://thenounproject.com/Yelena
  @sunset_icon """
  <svg xmlns="http://www.w3.org/2000/svg"
    xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" x="0px" y="0px" viewBox="0 0 100 102.5" enable-background="new 0 0 100 82" xml:space="preserve">
    <polygon points="100,53 100,47 0,47 0,53 44,53 44,57 34,57 50,82 66,57 56,57 56,53 "/>
    <path d="M50,18c-13.807,0-25,11.192-25,25h25h25C75,29.192,63.807,18,50,18z"/>
    <g>
      <path d="M10.088,24.211C9.75,24.079,9.385,24,9,24c-1.658,0-3,1.344-3,3c0,1.271,0.794,2.353,1.912,2.789L7.91,29.795l14.001,5.464   l2.181-5.59l-14.001-5.464L10.088,24.211z"/>
      <path d="M34.731,1.771C34.261,0.729,33.218,0,32,0c-1.658,0-3,1.344-3,3c0,0.439,0.1,0.853,0.269,1.229l-0.005,0.002l6.3,14   l5.472-2.462l-6.3-14L34.731,1.771z"/>
      <path d="M94,27c0-1.656-1.342-3-3-3c-0.385,0-0.75,0.079-1.089,0.211l-0.002-0.006l-14.002,5.464l2.182,5.59l14.002-5.464   l-0.002-0.006C93.206,29.353,94,28.271,94,27z"/>
      <path d="M68,0c-1.218,0-2.261,0.729-2.73,1.771l-0.005-0.002l-0.026,0.06c-0.001,0.002-0.002,0.004-0.003,0.006l-6.271,13.934   l5.471,2.462l6.3-14l-0.004-0.002C70.9,3.853,71,3.439,71,3C71,1.344,69.658,0,68,0z"/>
    </g>
  </svg>
  """

  # Icon by Yelena Polyakov https://thenounproject.com/Yelena
  @sunrise_icon """
  <svg xmlns="http://www.w3.org/2000/svg"
    xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" x="0px" y="0px" viewBox="0 0 100 102.5" enable-background="new 0 0 100 82" xml:space="preserve">
    <g>
      <path d="M50,18c-13.807,0-25,11.192-25,25h25h25C75,29.192,63.807,18,50,18z"/>
      <g>
        <path d="M10.088,24.211C9.75,24.079,9.385,24,9,24c-1.658,0-3,1.344-3,3c0,1.271,0.794,2.353,1.912,2.789L7.91,29.795    l14.001,5.464l2.181-5.59l-14.001-5.464L10.088,24.211z"/>
        <path d="M34.731,1.771C34.261,0.729,33.218,0,32,0c-1.658,0-3,1.344-3,3c0,0.439,0.1,0.853,0.269,1.229l-0.005,0.002l6.3,14    l5.472-2.462l-6.3-14L34.731,1.771z"/>
        <path d="M94,27c0-1.656-1.342-3-3-3c-0.385,0-0.75,0.079-1.089,0.211l-0.002-0.006l-14.002,5.464l2.182,5.59l14.002-5.464    l-0.002-0.006C93.206,29.353,94,28.271,94,27z"/>
        <path d="M68,0c-1.218,0-2.261,0.729-2.73,1.771l-0.005-0.002l-0.026,0.06c-0.001,0.002-0.002,0.004-0.003,0.006l-6.271,13.934    l5.471,2.462l6.3-14l-0.004-0.002C70.9,3.853,71,3.439,71,3C71,1.344,69.658,0,68,0z"/>
      </g>
      <rect y="47" width="100" height="6"/>
      <polygon points="44,82 56,82 56,78 66,78 50,53 34,78 44,78  "/>
    </g>
  </svg>
  """
  def render(assigns) do
    sunrise_icon = @sunrise_icon
    sunset_icon = @sunset_icon

    ~L"""
      <div>
        <ul>
          <%= for %{date: date, sunrise: sunrise, sunset: sunset} <- @days do %>
          <li>
            <h2><%= format_date(date, assigns) %></h2/>
            <div class="times">
              <div class="sunrise">
                <%= Phoenix.HTML.raw(sunrise_icon) %>
                <%= sunrise %>
              </div>
              <div class="sunset">
                <%= Phoenix.HTML.raw(sunset_icon) %>
                <%= sunset %>
              </div>
            </div>
          </li>
          <% end %>
        </ul>
      </div>
    """
  end

  defp format_date(date, assigns) do
    locale = get_option(assigns, :locale)
    Timex.lformat!(date, "{WDfull} {D} {Mshort}", locale)
  end

  def handle_info(:updated, socket) do
    {:noreply, update(socket)}
  end

  def update(socket) do
    days = Suntime.Server.days()
    assign(socket, :days, days)
  end

  def applications(options) do
    [
      {Suntime.Server, options}
    ]
  end
end
