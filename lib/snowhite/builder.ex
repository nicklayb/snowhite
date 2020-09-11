defmodule Snowhite.Builder do

  defmacro profile(name, module) do
    quote do
      @profiles Map.put(@profiles, unquote(name), unquote(module))
    end
  end

  defmacro __before_compile__(_) do
    quote do
      def profiles, do: @profiles
      def applications, do: Enum.flat_map(profiles(), fn {_, module} -> module.applications end)
    end
  end
end
