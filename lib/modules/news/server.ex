defmodule Snowhite.Modules.News.Server do
  use GenServer

  alias Snowhite.Modules.News.Item
  alias Snowhite.Modules.News.Feed
  alias Snowhite.UrlShortener
  import Snowhite.Helpers.Timing
  require Logger

  @auto_sync_timer ~d(15m)

  @spec start_link(any) :: GenServer.on_start()
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @doc "Updates the news feed"
  @spec update() :: :ok
  def update do
    GenServer.cast(__MODULE__, :update)
  end

  @doc "Gets server's news feeds"
  @spec news() :: [{String.t(), [Item.t()]}]
  def news do
    GenServer.call(__MODULE__, :news)
  end

  @impl GenServer
  def init(options) do
    {feeds, options} = Keyword.pop!(options, :feeds)
    Logger.info("[#{__MODULE__}] Started with #{length(feeds)} feeds")
    send(self(), :auto_sync)
    {:ok, %{options: options, feeds: init_feeds(feeds), news: []}}
  end

  @impl GenServer
  def handle_cast(:update, state) do
    send(self(), :notify)
    {:noreply, update(state)}
  end

  @impl GenServer
  def handle_call(:news, _, %{news: news} = state) do
    {:reply, news, state}
  end

  @impl GenServer
  def handle_info(:auto_sync, %{options: options} = state) do
    state = update(state)
    update_later(options)
    send(self(), :notify)
    {:noreply, state}
  end

  def handle_info(:notify, state) do
    Phoenix.PubSub.broadcast!(Snowhite.PubSub, "snowhite:modules:news", :updated)
    {:noreply, state}
  end

  defp update(%{feeds: feeds} = state) do
    news = Enum.map(feeds, &map_item(&1, state))

    %{state | news: news}
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

  defp update_later(options) do
    Process.send_after(self(), :auto_sync, Keyword.get(options, :refresh, @auto_sync_timer))
  end

  defp init_feeds(feeds) do
    Enum.map(feeds, &Feed.new/1)
  end
end
