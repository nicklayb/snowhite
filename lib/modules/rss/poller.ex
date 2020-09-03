defmodule Snowhite.Modules.Rss.Poller do
  require Logger

  def poll(feeds) when is_list(feeds) do
    tasks =
      Enum.map(feeds, fn {name, feed} ->
        {name, Task.async(fn -> poll(feed) end)}
      end)

    Enum.map(tasks, fn {name, pid} ->
      with {:ok, feed} <- Task.await(pid) do
        {name, feed}
      else
        _ -> {name, nil}
      end
    end)
  end

  def poll(feed) when is_bitstring(feed) do
    with {:ok, %{status_code: 200, body: body}} <- call(feed),
         {:ok, feed} <- ElixirFeedParser.parse(body) do
      {:ok, feed}
    else
      {:ok, %{status_code: status}} -> {:error, status}
      err -> err
    end
  end

  defp call(feed) do
    result = HTTPoison.get(feed)

    case result do
      {:ok, %{status_code: status}} ->
        Logger.info("[#{__MODULE__}] [#{status}] #{feed}")

      error ->
        Logger.warn("[#{__MODULE__}] [#{inspect(error)}] #{feed}")
    end

    result
  end
end
