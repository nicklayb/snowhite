defmodule Snowhite.Modules.News.Feed do
  @moduledoc """
  News Feed structure
  """
  defstruct [:name, :url, :adapter, :options]

  require Logger

  alias __MODULE__

  @default_adapter Snowhite.Modules.News.Adapters.Rss

  @type init_arguments ::
          {String.t(), String.t()}
          | %{name: String.t(), url: String.t(), adapter: module(), options: map()}

  @type t :: %Feed{name: String.t(), url: String.t(), adapter: module(), options: map()}

  @doc "Initialize a feed structure"
  @spec new(init_arguments()) :: t()
  def new({name, url}) do
    new(%{name: name, url: url, adapter: @default_adapter, options: %{}})
  end

  def new(%{name: name, url: url, adapter: adapter, options: options}) do
    %Feed{name: name, url: url, adapter: adapter, options: options}
  end

  def call_adapter(%Feed{name: name, url: url, adapter: adapter, options: options}) do
    Logger.info("[#{inspect(adapter)}] [#{name}] Polling #{url}")
    news = apply(adapter, :fetch, [url, options])
    Logger.info("[#{inspect(adapter)}] [#{name}] got #{length(news)} news")
    news
  end
end
