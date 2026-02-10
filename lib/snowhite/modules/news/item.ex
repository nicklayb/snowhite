defmodule Snowhite.Modules.News.Item do
  @moduledoc """
  News feed item
  """
  defstruct [:id, :title, :original_url, :short_url, :date, :qr_code]

  alias __MODULE__

  @type t :: %Item{
          title: String.t(),
          original_url: String.t(),
          short_url: String.t(),
          date: String.t(),
          qr_code: EQRCode.Matrix.t()
        }
end
