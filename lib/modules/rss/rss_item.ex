defmodule Snowhite.Modules.Rss.RssItem do
  alias __MODULE__
  defstruct id: nil, title: nil, original_link: nil, link: nil, qr_code: nil, updated: nil

  alias Snowhite.Modules.Rss.UrlShortener

  def new(entry, options \\ []) do
    link = Map.get(entry, :"rss2:link")

    %RssItem{
      id: entry.id,
      title: String.trim(entry.title),
      original_link: link,
      updated: entry.updated
    }
    |> shorten_link(options)
    |> put_qr_code(options)
  end

  defp put_qr_code(%RssItem{link: link} = item, options) do
    if Keyword.get(options, :qr_codes, true) do
      %RssItem{item | qr_code: EQRCode.encode(link)}
    else
      item
    end
  end

  defp shorten_link(%RssItem{original_link: link} = item, options) do
    short = if Keyword.get(options, :short_link, true), do: shorten_link(link), else: link

    %RssItem{item | link: short}
  end

  defp shorten_link(link) when is_bitstring(link) do
    case UrlShortener.shorten(link) do
      nil -> link
      short -> short
    end
  end
end
