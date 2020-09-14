defmodule SnowhiteWeb.Plug.PutProfileTest do
  use SnowhiteWeb.ConnCase

  alias SnowhiteWeb.Plug.PutProfile

  @profiles %{
    default: Profile.Default,
    other: Profile.Other
  }

  describe "init/1" do
    test "should accept a map of profiles" do
      assert %{profiles: @profiles} = PutProfile.init(profiles: @profiles)
    end
  end

  describe "call/2" do
    test "should put default profile if no header or param is present", %{conn: conn} do
      assert %{assigns: %{profile: Profile.Default}} = call_plug(conn)
    end

    test "should put header profile", %{conn: conn} do
      conn = put_req_header(conn, "x-snowhite-profile", "other")

      assert %{assigns: %{profile: Profile.Other}} = call_plug(conn)
    end

    test "should put param profile", %{conn: conn} do
      conn = %Plug.Conn{conn | query_string: "snowhite_profile=other"}

      assert %{assigns: %{profile: Profile.Other}} = call_plug(conn)
    end

    test "should set profile to nil if profile doesn't exist", %{conn: conn} do
      conn = put_req_header(conn, "x-snowhite-profile", "unknown")

      assert %{assigns: %{profile: nil}} = call_plug(conn)
    end
  end

  def call_plug(conn) do
    PutProfile.call(conn, PutProfile.init(profiles: @profiles))
  end
end
