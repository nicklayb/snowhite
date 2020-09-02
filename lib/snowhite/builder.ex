defmodule Snowhite.Builder do
  defmacro register_module(module, options \\ []) do
    quote do
      @registered_modules [{unquote(module), unquote(options)} | @registered_modules]
    end
  end

  defmacro __using__(_) do
    quote do
      import Snowhite.Builder
      @before_compile {Snowhite.Builder, :__before_compile__}
      @registered_modules []
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def modules, do: @registered_modules
    end
  end
end
