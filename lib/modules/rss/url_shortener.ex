defmodule Snowhite.Modules.Rss.UrlShortener do
  @moduledoc """
  Shortens url using Bitly and keeps the value persisted in a dets table
  """
  use GenServer
  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def shorten(link) do
    GenServer.cast(__MODULE__, {:shorten, link})
    GenServer.call(__MODULE__, {:get, link})
  end

  def all do
    GenServer.call(__MODULE__, :all)
  end

  def init(args) do
    persist_app = Keyword.fetch!(args, :persist_app)
    dets = init_dets(persist_app)
    urls = fetch_persisted_urls(dets)
    {:ok, %{urls: urls, dets: dets}}
  end

  def handle_cast({:shorten, long_url}, state) do
    with {:error, :missing} <- find_short_url(state, long_url),
         {:ok, short_url} <- shorten_url(long_url) do
      {:noreply, persist(state, {long_url, short_url})}
    else
      _ ->
        {:noreply, state}
    end
  end

  def handle_call({:get, link}, _, state) do
    url =
      case find_short_url(state, link) do
        {:ok, url} -> url
        {:error, _} -> nil
      end

    {:reply, url, state}
  end

  def handle_call(:all, _, %{urls: urls} = state) do
    {:reply, urls, state}
  end

  defp shorten_url(url) do
    with %Bitly.Link{status_code: 200, data: %{url: short_url}} <- Bitly.Link.shorten(url) do
      Logger.info("[#{__MODULE__}] #{url} -> #{short_url}")
      {:ok, short_url}
    else
      data ->
        Logger.warn("[#{__MODULE__}] error: #{inspect(data)}")
        {:error, data}
    end
  end

  defp find_short_url(%{urls: urls}, link) do
    short = Map.get(urls, link)

    if is_nil(short) do
      {:error, :missing}
    else
      {:ok, short}
    end
  end

  defp persist(%{dets: dets} = state, {long, short}) do
    update_dets(dets, {long, short})
    put_in(state, [:urls, long], short)
  end

  defp update_dets(nil, _), do: :dets_empty

  defp update_dets(%{file: file}, {long, short}) do
    :dets.insert_new(file, {long, short})
  end

  @select_all [{:"$1", [], [:"$1"]}]
  defp fetch_persisted_urls(%{file: file}) do
    file
    |> :dets.select(@select_all)
    |> Enum.into(%{})
  end

  defp fetch_persisted_urls(_), do: %{}

  @default_path ["dets", "short_urls.dets"]
  defp init_dets(app) do
    {app, path} =
      case app do
        {app, path} -> {app, path}
        app -> {app, @default_path}
      end

    priv_path = Snowhite.Helpers.Path.priv_path(app, path)
    {:ok, dets} = :dets.open_file(String.to_atom(priv_path), type: :set)

    %{priv_path: priv_path, file: dets}
  rescue
    _ -> nil
  end
end
