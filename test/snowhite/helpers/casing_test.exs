defmodule Snowhite.Helpers.CasingTest do
  use Snowhite.TestCase

  alias Snowhite.Helpers.Casing

  describe "normalize_module/1" do
    test "normalizes module name" do
      assert "Some.Module" = Casing.normalize_module(Some.Module)
      assert "Snowhite.Modules.Clock" = Casing.normalize_module(Snowhite.Modules.Clock)
    end
  end

  describe "topic/1" do
    test "cases module as topic name" do
      assert "some:module" = Casing.topic(Some.Module)
      assert "snowhite:modules:clock" = Casing.topic(Snowhite.Modules.Clock)
    end
  end

  describe "class/1" do
    test "cases module as HTML class" do
      assert "some-module" = Casing.class(Some.Module)
      assert "snowhite-modules-clock" = Casing.class(Snowhite.Modules.Clock)
    end
  end

  describe "config_key/1" do
    test "cases module as config key" do
      assert :some_module = Casing.config_key(Some.Module)
      assert :clock = Casing.config_key(Snowhite.Modules.Clock)
    end
  end
end
