defmodule SnowhiteWeb.Plug.PutProfile do
  @behaviour Plug
  import Plug.Conn

  def init(opts) do
    profiles = Keyword.fetch!(opts, :profiles)

    IO.inspect(profiles)
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

    if profile_exists?(profile_name, profiles) do
      Map.get(profiles, String.to_existing_atom(profile_name))
    else
      nil
    end
  end

  defp profile_exists?(lookup_profile, profiles) do
    Enum.any?(profiles, fn {profile, _} ->
      IO.inspect({profile, profiles})
      to_string(profile) == lookup_profile
    end)
  end

  @profile_header "X-Snowhite-Profile"
  @profile_param "snowhite_profile"
  @fallback_profile "default"
  defp get_profile_name(%Plug.Conn{} = conn) do
    case get_req_header(conn, @profile_header) do
      [profile | _] -> profile
      [] -> get_profile_from_params(conn)
    end
  end

  defp get_profile_from_params(%Plug.Conn{query_params: %Plug.Conn.Unfetched{}} = conn),
    do: fetch_query_params(conn)

  defp get_profile_from_params(%Plug.Conn{query_params: %{@profile_param => profile}}),
    do: profile

  defp get_profile_from_params(%Plug.Conn{}), do: @fallback_profile
end
