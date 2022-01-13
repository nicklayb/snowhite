defmodule Snowhite.Modules.News.Adapter do
  @moduledoc """
  Adapter for a given news feed. By default when you use the News module, it uses
  the RSS adapter because it assumes that the news feed you provided is a RSS feed.

  To use another adapter, simply implements the following callback. You can also
  look at the provided adapters to see one matches your needs.
  """
  @callback fetch(url :: String.t(), options :: map()) :: [News.Item.t()]
end
