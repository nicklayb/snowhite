defmodule Snowhite.Modules.News.Server do
  use Snowhite.StateServer, pubsub_topic: "snowhite:modules:news"

  alias Snowhite.StateServer.Configuration
  alias Snowhite.Modules.News.Item
  alias Snowhite.Modules.News.Feed
  alias Snowhite.UrlShortener

  @impl Snowhite.StateServer
  def init_state(options) do
    {feeds, options} = Keyword.pop!(options, :feeds)

    feeds = Enum.map(feeds, &Feed.new/1)
    news = Enum.map(feeds, fn %Feed{name: name} -> {name, []} end)

    state = %{feeds: feeds, options: options, news: news}

    {:ok, state}
  end

  @refresh_default_timer :timer.minutes(15)
  @impl Snowhite.StateServer
  def init_configuration(options) do
    %Configuration{update_timer: Keyword.get(options, :refresh, @refresh_default_timer)}
  end

  @impl Snowhite.StateServer
  def handle_update(%{feeds: feeds} = state, _configuration) do
    async(state, :fetch_news, fn state -> Enum.map(feeds, &map_item(&1, state)) end)

    :ignore
  end

  @impl Snowhite.StateServer
  def handle_async(:fetch_news, _ref, news, state, _configuration) do
    {:ok, %{state | news: news}}
  end

  @impl Snowhite.StateServer
  def handle_state_call(%{news: news}, _configuration) do
    news
  end

  defp map_item(%Feed{name: name} = feed, state) do
    news =
      feed
      |> Feed.call_adapter()
      |> Enum.map(fn item ->
        item
        |> shorten_url(state)
        |> put_qr_code(state)
      end)
      |> Enum.sort_by(& &1.date, {:desc, DateTime})

    {name, news}
  end

  defp put_qr_code(%Item{short_url: short_url} = item, %{options: options}) do
    if Keyword.get(options, :qr_codes, true) do
      %Item{item | qr_code: EQRCode.encode(short_url)}
    else
      item
    end
  end

  defp shorten_url(%Item{original_url: url} = item, %{options: options}) do
    short = if Keyword.get(options, :short_link, true), do: shorten_url(url), else: url

    %Item{item | short_url: short}
  end

  defp shorten_url(link) when is_bitstring(link) do
    case UrlShortener.shorten(link) do
      nil -> link
      short -> short
    end
  end

  def news(%{news: news}), do: news
end
