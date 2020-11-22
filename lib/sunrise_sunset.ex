defmodule SunriseSunset do
  require Logger
  @type coord :: {float(), float()}
  @spec get(coord(), Timex.Types.date()) :: {:ok, SunsetSunrise.Response.t()} | {:error, any()}
  def get(coord, date) do
    with {:ok, %{body: json}} <- call(path(coord, date)),
         {:ok, %{"status" => "OK", "results" => results}} <- Jason.decode(json) do
      Starchoice.decode(results, SunriseSunset.Response)
    else
      {:error, error} -> {:error, error}
      {:ok, %{"status" => status}} -> {:error, status}
      error -> {:error, error}
    end
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

  @base_url "https://api.sunrise-sunset.org/json"
  defp path({lng, lat}, date) do
    query = URI.encode_query(%{lng: lng, lat: lat, date: format_date(date), formatted: 0})
    Enum.join([@base_url, query], "?")
  end

  defp format_date(date), do: Enum.join([date.year, date.month, date.day], "-")
end
