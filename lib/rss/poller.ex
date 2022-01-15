defmodule Rss.Poller do
  @moduledoc """
  Polls a given list of feeds in parrallel.
  """
  require Logger

  alias Snowhite.Helpers.TaskRunner

  @doc """
  Polls given feeds in parrallel
  """
  @type feed :: [{String.t(), String.t()}] | String.t()
  @type loaded_feed :: {String.t(), [map()]} | {:error, any} | {:ok, any}
  @spec poll(feed()) :: loaded_feed()
  def poll(feeds) when is_list(feeds) do
    feeds
    |> Enum.map(&to_task_definition/1)
    |> TaskRunner.run(map_after: &unwrap/1)
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
    result = HTTPoison.get(feed, [], follow_redirect: true)

    case result do
      {:ok, %{status_code: status}} ->
        Logger.info("[#{inspect(__MODULE__)}] [#{status}] #{feed}")

      error ->
        Logger.warn("[#{inspect(__MODULE__)}] [#{inspect(error)}] #{feed}")
    end

    result
  end

  defp to_task_definition({name, feed}), do: {name, &poll/1, [feed]}

  defp unwrap({:ok, value}), do: value
  defp unwrap(_), do: nil
end
