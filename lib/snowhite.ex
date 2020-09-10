defmodule Snowhite do
  defmacro __using__(_) do
    quote do
      @before_compile {Snowhite.Builder, :__before_compile__}
      require Snowhite.Builder.Supervisor
      require Snowhite.Builder.Controller
      import Snowhite.Builder
      @profiles %{}

      Snowhite.Builder.Supervisor.build()
      Snowhite.Builder.Controller.build()
    end
  end

  defmacro snowhite_router(snowhite_app) do
    quote do
      get("/", unquote(snowhite_app).Controller, :index)
    end
  end
end
