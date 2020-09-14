defmodule SnowhiteWeb.Layouts.ViewTest do
  use SnowhiteWeb.ConnCase

  alias SnowhiteWeb.Layouts.View

  describe "route_helpers/1" do
    test "should get conn's router route helpers", %{conn: conn} do
      helper_module = View.route_helpers(conn)
      assert SnowhiteWeb.ConnCase.Router.Helpers = helper_module
      assert function_exported?(helper_module, :static_url, 2)
    end
  end
end
