defmodule Snowhite.Modules.News.Adapters.Rss do
  @moduledoc """
  Implements RSS feed lookup. The Feeds must have the following properties

  - `id` a unique identifier of the feed
  - `title` the title, most likely the headline of the article
  - `rss2:link` the url to read the news. This will be used to generate the QR code.
  - `date` date at which the article has been published.

  The RSS adapter doesn't support any options by now.
  """
  @behaviour Snowhite.Modules.News.Adapter

  alias Snowhite.Helpers.List, as: ListHelper
  alias Snowhite.Modules.News.Item

  def fetch(url, _) do
    with {:ok, result} <- Snowhite.Client.Rss.Poller.poll(url) do
      ListHelper.filter_map(result, &valid?/1, &to_rss_item/1)
    else
      _ -> []
    end
  end

  defp to_rss_item(entry) do
    %Item{
      id: Map.get(entry, "link"),
      original_url: Map.get(entry, "link"),
      date: parse_date(Map.get(entry, "pub_date")),
      title: String.trim(Map.get(entry, "title", ""))
    }
  end

  defp parse_date(date) do
    Timex.parse!(date, "{RFC1123}")
  end

  @required_fields ["link", "pub_date", "title"]
  defp valid?(item) do
    Enum.all?(@required_fields, fn field ->
      not (item
           |> Map.get(field)
           |> is_nil())
    end)
  end
end
