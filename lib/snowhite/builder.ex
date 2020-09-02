defmodule Snowhite.Builder do
  alias Snowhite.Helpers.Map, as: MapHelpers
  alias Snowhite.Builder.Layout

  defmacro register_module(position, module, options \\ []) do
    if position not in Layout.positions(),
      do:
        raise(
          "Wrong position `#{position}`; expected combo of [top|middle|bottom]_[left|middle|right]"
        )

    options = [{:_position, position} | options]

    quote do
      @layout MapHelpers.append(
                @layout,
                unquote(position),
                {unquote(module), unquote(options)}
              )
    end
  end

  defmacro __using__(_) do
    quote do
      import Snowhite.Builder
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
