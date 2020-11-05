defmodule Snowhite.Modules.Rss.Server do
  @moduledoc """
  Server that holds polled feeds and syncs them
  """
  use GenServer
  import Snowhite.Helpers.Timing
  require Logger
  alias Snowhite.Modules.Rss.Poller
  alias Snowhite.Modules.Rss.RssItem

  @auto_sync_timer ~d(15m)

  @type feed :: {String.t(), String.t()}

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def update do
    GenServer.cast(__MODULE__, :update)
  end

  def news do
    GenServer.call(__MODULE__, :news)
  end

  @spec init(keyword) :: {:ok, %{feeds: any, news: [], options: [{any, any}]}}
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
      |> Enum.map(fn
        {name, %{entries: entries}} ->
          entries =
            entries
            |> Enum.reject(&invalid?/1)
            |> Enum.map(&RssItem.new(&1))

          {name, entries}

        {name, _} ->
          {name, []}
      end)

    %{state | news: news}
  end

  @required_fields [:id, :title, :"rss2:link", :updated]
  defp invalid?(item) do
    Enum.any?(@required_fields, fn field ->
      item
      |> Map.get(field)
      |> is_nil()
    end)
  end
end
