defmodule Snowhite.Helpers.ListTest do
  use Snowhite.TestCase

  alias Snowhite.Helpers.List, as: ListHelper

  describe "cycle/1" do
    test "should cycle from 1 elements" do
      assert [2, 3, 4, 1] = ListHelper.cycle([1, 2, 3, 4])
      assert [] = ListHelper.cycle([])
    end
  end

  describe "cycle/2" do
    test "should cycle from 3 elements" do
      assert [4, 1, 2, 3] = ListHelper.cycle([1, 2, 3, 4], 3)
      assert [] = ListHelper.cycle([], 3)
    end

    test "should cycle from higher length than list length" do
      assert [2, 3, 4, 1] = ListHelper.cycle([1, 2, 3, 4], 9)
    end
  end
end
