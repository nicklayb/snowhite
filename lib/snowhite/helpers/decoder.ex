defmodule Snowhite.Helpers.Decoder do
  @doc """
  Makes a structure decodable easily. This comes in handy to decode json structure from apis.

  It makes any string-keyed map decodable as a struct. If you want to transform a value before adding it to the map, just override `decode_field/2` function and pattern match on the key (first parameter).

  ## Examples

  In the examples below, you'll notice that the

  ```
  defmodule User do
    @keys :name, :email, :posts
    defstruct @keys
    use Snowhite.Helpers.Decoder, @keys

    def decode_field(:posts, posts), do: Enum.map(posts, &Post.decode/1)
    def decode_field(:email, email), do: String.downcase(email)
    def decode_field(_, value), do: value # required as we are overriding the function
  end
  defmodule Post do
    @keys :title, :body
    defstruct @keys
  end
  iex> User.decode(%{"name" => "Bobby Hill", "email" => "BobbyHill@kingofthehill.com", "posts" => [%{"title" => "Being bobby", "body" => "..."}]})
  %User{
    name: "Bobby Hill",
    email: "bobbyhill@kingofthehill.com",
    posts: [
      %Post{title: "Being Bobby", body: "..."}
    ]
  }
  ```
  """
  @spec __using__([atom()]) :: Macro.t()
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
