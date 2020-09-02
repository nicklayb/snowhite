defmodule Snowhite.Builder do
  alias Snowhite.Builder.Layout

  defmacro register_module(position, module, options \\ []) do
    if position not in Layout.positions(),
      do:
        raise(
          "Wrong position `#{position}`; expected combo of [top|middle|bottom]_[left|middle|right]"
        )

    options = [{:_position, position} | options]

    module_def = {module, options}

    quote do
      @layout Layout.put_module(@layout, unquote(position), unquote(module_def))
    end
  end

  defmacro __using__(_) do
    quote do
      import Snowhite.Builder
      import Snowhite.Helpers.Timing
      @before_compile {Snowhite.Builder, :__before_compile__}
      @layout %Snowhite.Builder.Layout{}
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def layout, do: @layout
    end
  end
end
