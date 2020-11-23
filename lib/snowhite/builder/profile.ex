defmodule Snowhite.Builder.Profile do
  alias Snowhite.Builder.Layout

  defmacro register_module(position, module, options \\ []) do
    if position not in Layout.positions(),
      do:
        raise(
          "Wrong position `#{position}`; expected combo of [top|middle|bottom]_[left|middle|right]"
        )

    quote do
      @layout Layout.put_module(
                @layout,
                unquote(position),
                {unquote(module),
                 ensure_options(unquote(module).module_options, unquote(options), @global_options)}
              )
    end
  end

  defmacro __using__(_) do
    quote do
      import Snowhite.Builder.Profile
      import Snowhite.Helpers.Timing
      @before_compile {Snowhite.Builder.Profile, :__before_compile__}
      @layout %Snowhite.Builder.Layout{}
      @global_options []
    end
  end

  defmacro configure(options) do
    quote do
      @global_options unquote(options)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def layout, do: @layout

      def applications do
        layout()
        |> Layout.modules()
        |> Enum.flat_map(fn {module, options} ->
          module.applications(options)
        end)
      end
    end
  end

  def ensure_options(pattern, options, global_options) do
    {valid_options, invalid_options} =
      Enum.reduce(pattern, {[], apply_global_options(pattern, options, global_options)}, fn
        {key, :required}, {valid_options, rest_options} ->
          if not Keyword.has_key?(rest_options, key),
            do: raise("Required option `:#{key}` not provided")

          {value, rest_options} = Keyword.pop!(rest_options, key)

          {[{key, value} | valid_options], rest_options}

        {key, {:optional, fallback}}, {valid_options, rest_options} ->
          {value, rest_options} = Keyword.pop(rest_options, key, fallback)

          {[{key, value} | valid_options], rest_options}
      end)

    case invalid_options do
      [option | _] -> raise "Unsupported option `#{inspect(option)}` provided"
      _ -> valid_options
    end
  end

  def apply_global_options(pattern, options, global_options) do
    Enum.reduce(pattern, options, fn {key, _}, acc ->
      cond do
        Keyword.has_key?(acc, key) ->
          acc

        Keyword.has_key?(global_options, key) ->
          Keyword.put(acc, key, Keyword.get(global_options, key))

        true ->
          acc
      end
    end)
  end
end
