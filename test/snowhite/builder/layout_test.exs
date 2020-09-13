defmodule Snowhite.Builder.LayoutTest do
  use Snowhite.TestCase

  alias Snowhite.Builder.Layout

  describe "positions/0" do
    @positions ~w(
      top_left    top_center    top_right
      middle_left middle_center middle_right
      bottom_left bottom_center bottom_right
    )a
    test "should get all possible positions" do
      assert @positions = Layout.positions()
    end
  end

  describe "modules/1" do
    test "returns all modules of a given layout" do
      layout = %Layout{
        top_left: [
          {SomeModule, [1]}
        ],
        bottom_right: [
          {SomeOtherModule, [:some, :args]}
        ]
      }

      assert [{SomeModule, [1]}, {SomeOtherModule, [:some, :args]}] = Layout.modules(layout)
    end
  end

  describe "put_module/3" do
    test "should put a module to a given position" do
      layout = %Layout{}
      assert layout = Layout.put_module(layout, :top_left, {SomeModule, [1]})
      assert %Layout{top_left: [{SomeModule, [1]}]} = layout
      assert layout = Layout.put_module(layout, :top_left, {SomeOtherModule, [:some, :args]})
      assert %Layout{top_left: [{SomeModule, [1]}, {SomeOtherModule, [:some, :args]}]} = layout
    end

    test "should raise if the position does not exists" do
      assert_raise ArgumentError, fn ->
        Layout.put_module(%Layout{}, :middle_of_nowhere, {SomeModule, [1]})
      end
    end
  end
end
