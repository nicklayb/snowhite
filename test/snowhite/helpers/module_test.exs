defmodule Snowhite.Helpers.ModuleTest do
  use Snowhite.TestCase

  alias Snowhite.Helpers.Module, as: ModuleHelper

  describe "parent_module/1" do
    test "should return parent module" do
      assert Snowhite.Helpers = ModuleHelper.parent_module(Snowhite.Helpers.Module)

      assert Snowhite.Modules.Weather =
               ModuleHelper.parent_module(Snowhite.Modules.Weather.Forecast)

      assert Snowhite.Modules = ModuleHelper.parent_module(Snowhite.Modules.Weather)
    end

    test "should return nil if module has no parent" do
      assert is_nil(ModuleHelper.parent_module(Snowhite))
      assert is_nil(ModuleHelper.parent_module(Enum))
    end
  end
end
