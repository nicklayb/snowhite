defmodule Snowhite.Client.UrlShortener.Noop do
  @behaviour Snowhite.UrlShortener

  @impl Snowhite.UrlShortener
  def shorten(url) do
    {:ok, url}
  end
end
