defmodule Snowhite.Helpers.MapTest do
  use Snowhite.TestCase

  alias Snowhite.Helpers.Map, as: MapHelpers

  describe "append/3" do
    test "appends to map where the value doesn't exists" do
      value = 1
      assert %{key: [^value]} = MapHelpers.append(%{}, :key, value)
    end

    test "appends to map where the value exists" do
      value = 2
      assert %{key: [1, ^value]} = MapHelpers.append(%{key: [1]}, :key, value)
    end
  end
end
