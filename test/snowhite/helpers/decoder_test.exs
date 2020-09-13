defmodule Snowhite.Helpers.DecoderTest do
  use Snowhite.TestCase

  alias Snowhite.Helpers.Decoder

  defmodule Post do
    @keys ~w(title body)a
    defstruct @keys
    use Decoder, @keys
  end

  defmodule User do
    @keys ~w(name email posts)a
    defstruct @keys
    use Decoder, @keys

    def decode_field(:email, email), do: String.downcase(email)
    def decode_field(:posts, posts), do: Enum.map(posts, &Post.decode/1)
    def decode_field(_, value), do: value
  end

  describe "__using__/1" do
    setup do
      posts = [
        %Post{title: "Some title 1", body: "Body"},
        %Post{title: "Some title 2", body: "Another body"}
      ]

      user = %User{
        name: "Bobby Hill",
        email: "bobbyhill@kingofthehill.com",
        posts: posts
      }

      %{
        posts: posts,
        user: user,
        json: %{
          "name" => "Bobby Hill",
          "email" => "BobbyHill@KingOfTheHill.com",
          "posts" => [
            %{"title" => "Some title 1", "body" => "Body"},
            %{"title" => "Some title 2", "body" => "Another body"}
          ]
        }
      }
    end

    test "should decode one element", %{posts: [post | _], json: %{"posts" => [json | _]}} do
      assert ^post = Post.decode(json)
    end

    test "should decode multiple element", %{posts: posts, json: %{"posts" => json}} do
      assert ^posts = Post.decode(json)
    end

    test "should make decode_field/2 overridable", %{user: user, json: json} do
      assert ^user = User.decode(json)
    end
  end
end
