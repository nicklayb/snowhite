defmodule Snowhite.ProfileProvider do
  use Supervisor

  require Logger

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: Keyword.get(args, :name, __MODULE__))
  end

  def init(args) do
    Logger.info("[#{__MODULE__}] Initializing #{inspect(args)}")

    timezone = Keyword.get(args, :timezone, "UTC")

    profiles =
      args
      |> Keyword.fetch!(:file_path)
      |> load_chilren()

    profile_keys =
      Map.new(profiles, fn {_, options} ->
        profile_name = Keyword.fetch!(options, :profile_name)
        {profile_name, Snowhite.ProfileServer.name(profile_name)}
      end)

    Supervisor.init(
      [
        {Agent, fn -> profile_keys end},
        {Phoenix.PubSub, name: Snowhite.PubSub},
        {Snowhite.Scheduler, timezone: timezone}
        | profiles
      ],
      strategy: :one_for_one
    )
  end

  def reload do
    GenServer.stop(__MODULE__)
  end

  def profiles do
    __MODULE__
    |> Supervisor.which_children()
    |> Enum.find(&match?({Agent, _, _, _}, &1))
    |> then(fn {_, pid, _, _} -> pid end)
    |> Agent.get(& &1)
  end

  defp load_chilren(file_path) do
    file_path
    |> File.read!()
    |> YamlElixir.read_from_string!()
    |> build_profiles()
  rescue
    e ->
      Logger.error("[#{__MODULE__}] Failed to load profiles from #{file_path}: #{inspect(e)}")
      []
  end

  defp build_profiles(%{"profiles" => profiles} = configuration) do
    Enum.map(profiles, fn {name, profile_config} ->
      {Snowhite.ProfileServer,
       [
         profile_name: name,
         global_configuration: Map.get(configuration, "configuration", %{}),
         configuration: profile_config
       ]}
    end)
  end
end
