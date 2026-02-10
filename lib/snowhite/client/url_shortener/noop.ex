defmodule Snowhite.UrlShortener.Noop do
  @behaviour Snowhite.UrlShortener

  def shorten(url) do
    {:ok, url}
  end
end
