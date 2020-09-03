defmodule Snowhite.Modules.Rss do
  use Snowhite.Builder.Module

  alias __MODULE__

  every(~d(25s), :scroll, &scroll/1)

  def mount(socket) do
    socket =
      socket
      |> assign(:news, [])

    Rss.Server.update()

    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
      <ul class="feeds">
        <%= for {name, news} <- @news do %>
          <li>
            <%= name %>
            <ul class="news">
              <%= for item <- Enum.take(news, 3) do %>
                <li><%= item.title %></li>
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
    news = Rss.Server.news()

    {:noreply, assign(socket, :news, news)}
  end

  def applications(options) do
    feeds = Keyword.get(options, :feeds, [])

    [
      {Rss.Server, [feeds: feeds]}
    ]
  end
end
