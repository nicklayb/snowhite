defmodule Snowhite.UrlShortener.Bitly do
  @behaviour Snowhite.UrlShortener

  def shorten(url) do
    with %Bitly.Link{status_code: 200, data: %{url: short_url}} <- Bitly.Link.shorten(url) do
      {:ok, short_url}
    else
      data ->
        {:error, data}
    end
  end
end
