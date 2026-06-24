defmodule SnowhiteWeb.Plug.PutProfile do
  @behaviour Plug
  import Plug.Conn

  def init(opts) do
    profiles = Keyword.fetch!(opts, :profiles)

    %{
      profiles: profiles
    }
  end

  def call(conn, %{profiles: profiles}) do
    put_profile(conn, profiles)
  end

  defp put_profile(%Plug.Conn{} = conn, profiles) do
    profile = get_profile(conn, profiles)

    assign(conn, :profile, profile)
  end

  defp get_profile(%Plug.Conn{} = conn, profiles) do
    profile_name = get_profile_name(conn)

    Map.get(profiles, profile_name)
  end

  @profile_header "x-snowhite-profile"
  @profile_param "snowhite_profile"
  @fallback_profile "default"
  defp get_profile_name(%Plug.Conn{} = conn) do
    case get_req_header(conn, @profile_header) do
      [profile | _] -> profile
      [] -> get_profile_from_params(conn)
    end
  end

  defp get_profile_from_params(%Plug.Conn{query_params: %Plug.Conn.Unfetched{}} = conn) do
    conn
    |> fetch_query_params()
    |> get_profile_from_params()
  end

  defp get_profile_from_params(%Plug.Conn{query_params: %{@profile_param => profile}}),
    do: profile

  defp get_profile_from_params(%Plug.Conn{}), do: @fallback_profile
end
