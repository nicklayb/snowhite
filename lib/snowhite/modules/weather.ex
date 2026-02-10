defmodule Snowhite.Modules.Weather do
  import Snowhite.Helpers.Timing
  import Snowhite.Builder.Module

  alias __MODULE__

  def applications(options) do
    options = [{:api_key, module_config(:weather, :api_key)} | options]

    [
      {Weather.Server, options}
    ]
  end

  def module_options do
    %{
      city_id: :required,
      locale: {:optional, "en"},
      units: {:optional, :metric},
      refresh: {:optional, ~d(1h)}
    }
  end
end
