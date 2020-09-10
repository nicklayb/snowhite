defmodule Snowhite.Builder.Supervisor do
  defmacro build do
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
          Supervisor.init(profile_applications(), strategy: :one_for_one)
        end

        def profile_applications do
          Enum.dedup_by(@parent_module.applications(), fn {mod, _} -> mod end)
        end
      end
    end
  end
end
