defmodule Snowhite.ProfileServer do
  alias Snowhite.Builder.Layout
  use Supervisor

  require Logger

  def start_link(args) do
    name =
      args
      |> Keyword.fetch!(:profile_name)
      |> name()

    Supervisor.start_link(__MODULE__, args, name: name)
  end

  def init(args) do
    profile_name = Keyword.fetch!(args, :profile_name)
    configuration = Keyword.fetch!(args, :configuration)
    global_configuration = Keyword.fetch!(args, :global_configuration)

    with {:ok, layout} <- build_layout(configuration, global_configuration) do
      applications =
        layout
        |> Layout.modules()
        |> Enum.flat_map(fn {module, options} ->
          module.applications(options)
        end)
        |> Enum.uniq_by(fn {module, _} -> module end)

      children = [{Agent, fn -> layout end} | applications]

      Supervisor.init(children, strategy: :one_for_all)
    else
      error ->
        Logger.error("[#{inspect(__MODULE__)}] [#{profile_name}] #{inspect(error)}")
        :ignore
    end
  end

  def layout(profile_name) do
    profile_name
    |> name()
    |> Supervisor.which_children()
    |> Enum.find(&match?({Agent, _, _, _}, &1))
    |> then(fn {_, pid, _, _} -> Agent.get(pid, & &1) end)
  end

  def name(profile_name) do
    Module.concat(__MODULE__, profile_name)
  end

  defp build_layout(configuration, global_configuration) do
    layout = %Layout{}

    configuration
    |> Map.get("modules", %{})
    |> Enum.flat_map(fn {position, module_specs} ->
      Enum.map(module_specs, fn module_spec ->
        Map.put(module_spec, "position", String.to_existing_atom(position))
      end)
    end)
    |> Enum.reduce(layout, fn %{"position" => position, "module" => module} =
                                config,
                              layout ->
      module_atom = Module.safe_concat(["Elixir", module])

      options =
        cast_options(module_atom, Map.merge(global_configuration, Map.get(config, "params", %{})))

      Layout.put_module(layout, position, {module_atom, options})
    end)
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error("[#{inspect(__MODULE__)}] #{inspect(error)}")
      {:error, error}
  end

  defp cast_options(module, params) do
    Enum.reduce(module.module_options(), [], fn
      {key, {:optional, default}}, acc ->
        Keyword.put(acc, key, Map.get(params, to_string(key), default))

      {key, :required}, acc ->
        Keyword.put(acc, key, Map.fetch!(params, to_string(key)))
    end)
  end
end
