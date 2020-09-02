defmodule Snowhite.Helpers.Decoder do
  defmacro __using__(keys) do
    quote do
      def decode(list) when is_list(list), do: Enum.map(list, &decode/1)

      def decode(nil), do: nil

      def decode(json) do
        Enum.reduce(unquote(keys), %__MODULE__{}, fn field, struct ->
          raw = Map.get(json, to_string(field))

          Map.put(struct, field, decode_field(field, raw))
        end)
      end

      defp decode_field(_field, value), do: value

      defoverridable(decode_field: 2)
    end
  end
end
