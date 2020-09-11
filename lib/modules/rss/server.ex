defmodule Snowhite.Modules.Rss.Server do
  use GenServer
  import Snowhite.Helpers.Timing
  require Logger
  alias Snowhite.Modules.Rss.Poller
  alias Snowhite.Modules.Rss.UrlShortener

  @auto_sync_timer ~d(15m)

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def update do
    GenServer.cast(__MODULE__, :update)
  end

  def news do
    GenServer.call(__MODULE__, :news)
  end

  def init(options) do
    feeds = Keyword.fetch!(options, :feeds)
    Logger.info("[#{__MODULE__}] Started with #{length(feeds)} feeds")
    update()
    update_later(options)
    {:ok, %{options: options, feeds: feeds, news: []}}
  end

  def handle_cast(:update, state) do
    send(self(), :notify)
    {:noreply, update(state)}
  end

  def handle_call(:news, _, %{news: news} = state) do
    {:reply, news, state}
  end

  def handle_info(:auto_sync, %{options: options} = state) do
    state = update(state)
    update_later(options)
    send(self(), :notify)
    {:noreply, state}
  end

  def handle_info(:notify, state) do
    Phoenix.PubSub.broadcast!(Snowhite.PubSub, "snowhite:modules:rss", :updated)
    {:noreply, state}
  end

  defp update_later(options) do
    Process.send_after(self(), :auto_sync, Keyword.get(options, :refresh, @auto_sync_timer))
  end

  defp update(%{feeds: feeds} = state) do
    news =
      feeds
      |> Poller.poll()
      |> Enum.map(fn {name, rss} ->
        entries = put_short_url(state, rss.entries)

        {name, entries}
      end)

    %{state | news: news}
  end

  defp put_short_url(%{options: options}, entries) do
    if Keyword.get(options, :qr_codes, true) do
      Enum.map(entries, fn entry ->
        short =
          entry
          |> get_entry_url()
          |> UrlShortener.shorten()

        Map.put(entry, :short_link, short)
      end)
    else
      entries
    end
  end

  defp get_entry_url(entry) do
    Map.get(entry, :"rss2:link", nil)
  end
end
