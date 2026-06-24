defmodule Snowhite.ProfileTest do
  use Snowhite.TestCase

  alias Snowhite.Profile

  describe "positions/0" do
    @positions ~w(
      top_left    top_center    top_right
      middle_left middle_center middle_right
      bottom_left bottom_center bottom_right
    )a
    test "should get all possible positions" do
      assert @positions = Profile.positions()
    end
  end

  describe "modules/1" do
    test "returns all modules of a given layout" do
      layout = %Profile{
        top_left: [
          {SomeModule, [1]}
        ],
        bottom_right: [
          {SomeOtherModule, [:some, :args]}
        ]
      }

      assert [{SomeModule, [1]}, {SomeOtherModule, [:some, :args]}] = Profile.modules(layout)
    end
  end

  describe "put_module/3" do
    test "should put a module to a given position" do
      layout = %Profile{}
      assert layout = Profile.put_module(layout, :top_left, {SomeModule, [1]})
      assert %Profile{top_left: [{SomeModule, [1]}]} = layout
      assert layout = Profile.put_module(layout, :top_left, {SomeOtherModule, [:some, :args]})
      assert %Profile{top_left: [{SomeModule, [1]}, {SomeOtherModule, [:some, :args]}]} = layout
    end

    test "should raise if the position does not exists" do
      assert_raise ArgumentError, fn ->
        Profile.put_module(%Profile{}, :middle_of_nowhere, {SomeModule, [1]})
      end
    end
  end
end
