defmodule Snowhite.Modules.News do
  use Snowhite.Builder.Module

  alias __MODULE__

  every(~d(5s), :scroll, &scroll/1)

  def mount(socket) do
    socket = update(socket, News.Server.state())

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
    assigns = pull_options(assigns, [:visible_news, :qr_codes, :locale])

    ~H"""
      <ul class="feeds">
        <%= for {name, news} <- @news do %>
          <li>
            <%= name %>
            <ul class="news">
              <%= for item <- Enum.take(news, @visible_news) do %>
                <li>
                  <%= if @qr_codes, do: Phoenix.HTML.raw(render_qr_code(item)) %>
                  <div>
                    <a href={item.original_url}><%= item.title %></a>
                    <small><%= format_date(@locale, item.date) %></small>
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

  def render_qr_code(%{qr_code: qr_code}) do
    EQRCode.svg(qr_code, viewbox: true)
  end

  def scroll(%{assigns: %{news: news}} = socket) do
    news = Enum.map(news, fn {name, list} -> {name, ListHelpers.cycle(list)} end)

    assign(socket, :news, news)
  end

  def handle_info({:updated, news}, socket) do
    {:noreply, update(socket, news)}
  end

  defp update(socket, news) do
    assign(socket, :news, news)
  end

  def applications(options) do
    feeds = Keyword.get(options, :feeds, [])
    qr_codes = Keyword.get(options, :qr_codes, true)
    persist_app = Keyword.fetch!(options, :persist_app)

    [
      {News.Server, [feeds: feeds, qr_codes: qr_codes]},
      {Snowhite.UrlShortener, [persist_app: persist_app]}
    ]
  end
end
