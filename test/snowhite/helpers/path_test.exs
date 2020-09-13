defmodule Snowhite.Helpers.PathTest do
  use Snowhite.TestCase

  alias Snowhite.Helpers.Path, as: PathHelper

  describe "priv_path/1" do
    test "returns priv path for an application" do
      assert PathHelper.priv_path(:ex_unit) =~ "ex_unit/priv"
    end

    test "returns priv path for an application with a nested folder" do
      path = ["some", "nested", "folder"]
      assert PathHelper.priv_path(:ex_unit, path) =~ "ex_unit/priv/#{Enum.join(path, "/")}"
    end
  end
end
