defmodule Snowhite.Modules.Rss do
  use Snowhite.Builder.Module

  alias __MODULE__

  every(~d(25s), :scroll, &scroll/1)

  def mount(socket) do
    socket = update(socket)

    {:ok, socket}
  end

  def module_options do
    %{
      feeds: :required,
      visible_news: {:optional, 3},
      qr_codes: {:optional, true},
      locale: {:optional, "en"},
      persist_app: :required
    }
  end

  def render(assigns) do
    take = get_option(assigns, :visible_news)
    qr_code? = get_option(assigns, :qr_codes)
    locale = get_option(assigns, :locale)

    ~L"""
      <ul class="feeds">
        <%= for {name, news} <- @news do %>
          <li>
            <%= name %>
            <ul class="news">
              <%= for item <- Enum.take(news, take) do %>
                <li>
                  <%= if qr_code?, do: Phoenix.HTML.raw(render_qr_code(item)) %>
                  <div>
                    <a href="<%= item.id %>"><%= item.title %></a>
                    <small><%= format_date(locale, item.updated) %></small>
                  </div>
                </li>
              <% end %>
            </ul>
          </li>
        <% end %>
      </ul>
    """
  end

  def format_date(locale, %DateTime{} = datetime) do
    Timex.from_now(datetime, locale)
  end

  def render_qr_code(item) do
    item
    |> news_link()
    |> EQRCode.encode()
    |> EQRCode.svg(viewbox: true)
  end

  defp news_link(item) do
    case Map.get(item, :short_link) do
      nil -> item[:"rss2:link"]
      link -> link
    end
  end

  def scroll(%{assigns: %{news: news}} = socket) do
    news = Enum.map(news, fn {name, list} -> {name, ListHelpers.cycle(list)} end)

    assign(socket, :news, news)
  end

  def handle_info(:updated, socket) do
    {:noreply, update(socket)}
  end

  defp update(socket) do
    news = Rss.Server.news()

    assign(socket, :news, news)
  end

  def applications(options) do
    feeds = Keyword.get(options, :feeds, [])
    qr_codes = Keyword.get(options, :qr_codes, true)
    persist_app = Keyword.fetch!(options, :persist_app)

    [
      {Rss.Server, [feeds: feeds, qr_codes: qr_codes]},
      {Rss.UrlShortener, [persist_app: persist_app]}
    ]
  end
end
