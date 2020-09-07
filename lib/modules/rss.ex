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
      visible_news: {:optional, 3}
    }
  end

  def render(assigns) do
    take = get_option(assigns, :visible_news)

    ~L"""
      <ul class="feeds">
        <%= for {name, news} <- @news do %>
          <li>
            <%= name %>
            <ul class="news">
              <%= for item <- Enum.take(news, take) do %>
                <li><a href="<%= item.id %>"><%= item.title %></a></li>
              <% end %>
            </ul>
          </li>
        <% end %>
      </ul>
    """
  end

  def scroll(%{assigns: %{news: news}} = socket) do
    news =
      Enum.map(news, fn
        {name, [head | tail]} ->
          {name, tail ++ [head]}

        {name, []} ->
          {name, []}
      end)

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

    [
      {Rss.Server, [feeds: feeds]}
    ]
  end
end
