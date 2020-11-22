defmodule OpenWeather do
  require Logger

  @root_url "https://api.openweathermap.org/data/2.5"
  @current_weather_url "#{@root_url}/weather"
  @forecast_url "#{@root_url}/forecast"

  @ok_statuses 200..299

  def current_weather(api_key, params) do
    url = url(@current_weather_url, api_key, params)

    with {:ok, %{status_code: status, body: body}} when status in @ok_statuses <- call(url),
         {:ok, json} <- Jason.decode(body) do
      Starchoice.decode(json, OpenWeather.Weather)
    else
      {:ok, %{status_code: status}} -> {:error, status}
      err -> err
    end
  end

  def forecast(api_key, params) do
    url = url(@forecast_url, api_key, params)

    with {:ok, %{status_code: status, body: body}} when status in @ok_statuses <- call(url),
         {:ok, json} <- Jason.decode(body) do
      Starchoice.decode(json, OpenWeather.Forecast)
    else
      {:ok, %{status_code: status}} -> {:error, status}
      err -> err
    end
  end

  defp url(root_url, api_key, params) do
    query =
      %{appid: api_key}
      |> Map.merge(params)
      |> URI.encode_query()

    Enum.join([root_url, query], "?")
  end

  defp call(url) do
    result = HTTPoison.get(url)

    case result do
      {:ok, %{status_code: status}} ->
        Logger.info("[#{__MODULE__}] [#{status}] #{url}")

      {:error, error} ->
        Logger.warn("[#{__MODULE__}] failed: #{error}")
    end

    result
  end
end
