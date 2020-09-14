defmodule SnowhiteWeb.Profile.ViewTest do
  use SnowhiteWeb.ConnCase

  alias SnowhiteWeb.Profile.View
  alias Snowhite.Builder.Layout

  describe "layout/1" do
    test "should convert a layout to keyword list" do
      layout = %Layout{top_left: [{ModuleOne, []}], bottom_right: [{ModuleTwo, []}]}

      assert [
               top_left: [
                 {ModuleOne, []}
               ],
               top_center: [],
               top_right: [],
               middle_left: [],
               middle_center: [],
               middle_right: [],
               bottom_left: [],
               bottom_center: [],
               bottom_right: [
                 {ModuleTwo, []}
               ]
             ] = View.layout(layout)
    end
  end

  @expected [
    top_left: "pane top left",
    top_center: "pane top center",
    top_right: "pane top right",
    middle_left: "pane middle left",
    middle_center: "pane middle center",
    middle_right: "pane middle right",
    bottom_left: "pane bottom left",
    bottom_center: "pane bottom center",
    bottom_right: "pane bottom right"
  ]
  describe "pane_class/1" do
    test "should return html classes for a given layout position" do
      Enum.each(Layout.positions(), fn position ->
        value = Keyword.get(@expected, position)
        assert ^value = View.pane_class(position)
      end)
    end
  end
end
