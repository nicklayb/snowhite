defmodule Finnhub do
  @moduledoc """
  Finnhub client.

  To use the client, you are require to have a `FINNHUB_API_KEY` configured.
  """
  @finnhub_auth_header "X-Finnhub-Token"
  @base_path "https://finnhub.io/api/v1"
  @base_uri URI.parse(@base_path)

  require Logger

  @doc "Get symbol's quote"
  @spec quote(String.t()) :: {:ok, Finnhub.Quote.t()} | {:error, any()}
  def quote(symbol) do
    url = url("quote", %{"symbol" => symbol})

    with {:ok, %HTTPoison.Response{body: body, status_code: 200}} <-
           HTTPoison.get(url, headers(), follow_redirect: true),
         {:ok, json} <- Jason.decode(body) do
      Logger.info("[#{__MODULE__}] [#{symbol}] Polled")
      Starchoice.decode(json, Finnhub.Quote)
    else
      {:ok, %{status_code: status_code} = response} ->
        Logger.error("[#{__MODULE__}] [#{symbol}] [#{status_code}] Error polling #{symbol}")

        {:error, response}

      {:error, error} ->
        Logger.error("[#{__MODULE__}] [#{symbol}] #{inspect(error)}")

        {:error, error}
    end
  end

  defp headers do
    [
      {@finnhub_auth_header, api_key()},
      {"Content-Type", "application/json"}
    ]
  end

  defp api_key do
    Application.get_env(:snowhite, __MODULE__)[:api_key]
  end

  defp url(path, query) do
    URI.to_string(%URI{
      @base_uri
      | path: Path.join(@base_uri.path, path),
        query: URI.encode_query(query)
    })
  end
end
