defmodule Snowhite.Builder.Supervisor do
  defmacro build(opts \\ []) do
    timezone = Keyword.get(opts, :timezone, "UTC")

    quote do
      defmodule ApplicationSupervisor do
        require Snowhite.Helpers.Module
        @parent_module Snowhite.Helpers.Module.parent_module(__MODULE__)
        use Supervisor

        def start_link(_) do
          Supervisor.start_link(__MODULE__, [], name: __MODULE__)
        end

        @impl true
        def init(_) do
          children = default_children() ++ profile_applications()
          Supervisor.init(children, strategy: :one_for_one)
        end

        defp default_children do
          [
            {Phoenix.PubSub, name: Snowhite.PubSub},
            {Snowhite.Scheduler, timezone: unquote(timezone)}
          ]
        end

        def profile_applications do
          Enum.dedup_by(@parent_module.applications(), fn {mod, _} -> mod end)
        end
      end
    end
  end
end
