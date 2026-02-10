defmodule Snowhite.Modules.News.Adapters.Json do
  @moduledoc """
  The JSON adapter can be used to fetch JSON endpoints. It must have a `item_mapper`
  to know how each fields are mapped since every JSON endpoints behaves differently.
  It also supports couples of HTTP options to customize the underlying `HTTPoison.request/5`
  call.

  ## Options

  - `item_mapper` **required**: A MF (`{module, funciton}`) that received two arguments,
    the json payload and the options. This function must return a list of `Item.t()`.
  - `body` (default `GET`): The method to use for the HTTP call.
  - `headers` (default `[]`): Headers for the HTTP call.
  - `body` (default `""`): Body content, in case of a non-GET call.
  - `http_poison_options` (default `[]`): Other option for `HTTPoison`.
  """
  @behaviour Snowhite.Modules.News.Adapter

  def fetch(url, %{item_mapper: {module, function}} = options) do
    method = Map.get(options, :method, "GET")
    body = Map.get(options, :body, "")
    headers = Map.get(options, :headers, [])
    http_poison_options = Map.get(options, :http_poison_options, [])

    with {:ok, %{body: body}} <-
           HTTPoison.request(method, url, body, headers, http_poison_options),
         {:ok, json} <- Jason.decode(body) do
      apply(module, function, [json, options])
    else
      _error ->
        []
    end
  end
end
