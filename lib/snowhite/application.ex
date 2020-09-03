defmodule Snowhite.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      SnowhiteWeb.Telemetry,
      {Phoenix.PubSub, name: Snowhite.PubSub},
      SnowhiteWeb.Endpoint,
      Snowhite.ModuleSupervisor
    ]

    opts = [strategy: :one_for_one, name: Snowhite.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    SnowhiteWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
