defmodule SnowhiteDemo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, name: Snowhite.PubSub},
      SnowhiteDemo.Endpoint,
      SnowhiteApp.ApplicationSupervisor
    ]

    opts = [strategy: :one_for_one, name: Snowhite.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    SnowhiteDemo.Endpoint.config_change(changed, removed)
    :ok
  end
end
