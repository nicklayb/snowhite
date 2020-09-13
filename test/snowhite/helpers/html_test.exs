defmodule Snowhite.Helpers.HtmlTest do
  use Snowhite.TestCase

  alias Snowhite.Helpers.Html

  describe "classes/2" do
    test "should handle condition classes" do
      conditions = [
        {fn user -> user.age > 18 end, "is-adult"}
      ]

      assert "is-adult" = Html.classes(conditions, [%{age: 20}])
      assert "" = Html.classes(conditions, [%{age: 10}])
    end

    test "should handle binary classes" do
      conditions = [
        {fn user -> user.active end, "is-active", "is-inactive"}
      ]

      assert "is-active" = Html.classes(conditions, [%{active: true}])
      assert "is-inactive" = Html.classes(conditions, [%{active: false}])
    end

    test "should handle function classes" do
      conditions = [
        fn user -> "is-#{user.type}" end
      ]

      assert "is-admin" = Html.classes(conditions, [%{type: "admin"}])
      assert "is-user" = Html.classes(conditions, [%{type: "user"}])
    end

    test "should handle string classes" do
      conditions = [
        "user"
      ]

      assert "user" = Html.classes(conditions, [%{type: "admin"}])
    end

    test "should handle multiple type" do
      conditions = [
        {fn user -> user.age > 18 end, "is-adult"},
        {fn user -> user.active end, "is-active", "is-inactive"},
        fn user -> "is-#{user.type}" end,
        "user"
      ]

      assert "user is-admin is-active is-adult" =
               Html.classes(conditions, [%{active: true, age: 19, type: "admin"}])

      assert "user is-user is-inactive" =
               Html.classes(conditions, [%{active: false, age: 16, type: "user"}])
    end
  end
end
