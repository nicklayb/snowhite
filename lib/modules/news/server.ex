defmodule Snowhite.Modules.News.Server do
  use GenServer

  alias Snowhite.Helpers.List, as: ListHelpers
  alias Snowhite.Modules.News
  alias Snowhite.Modules.News.Item
  alias Snowhite.UrlShortener
  import Snowhite.Helpers.Timing
  require Logger

  @auto_sync_timer ~d(15m)

  @default_adapter News.Adapters.Rss

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
    news =
      feeds
      |> Task.async_stream(&poll_feed/1)
      |> ListHelpers.filter_map(&succeeded?/1, &map_item(&1, state))

    %{state | news: news}
  end

  defp map_item({:ok, {name, news}}, state) do
    news =
      Enum.map(news, fn item ->
        item
        |> shorten_url(state)
        |> put_qr_code(state)
      end)

    {name, news}
  end

  defp succeeded?({:ok, {_, _}}), do: true
  defp succeeded?(_), do: false

  defp poll_feed(%{name: name, url: url, options: options, adapter: adapter}) do
    news = apply(adapter, :fetch, [url, options])

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
    Enum.map(feeds, fn
      %{name: name, url: url} = params ->
        adapter = Map.get(params, :adapter, @default_adapter)
        options = Map.get(params, :options, %{})

        %{url: url, name: name, adapter: adapter, options: options}

      {name, url} when is_bitstring(url) ->
        %{url: url, name: name, adapter: @default_adapter, options: %{}}
    end)
  end
end
