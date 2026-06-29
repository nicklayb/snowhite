defmodule Snowhite.StateServer.State do
  defstruct [:configuration, :pubsub_topic, :update_timer, :module, :name, :internal_state]

  alias Snowhite.Scheduler
  alias Snowhite.StateServer.Configuration
  alias Snowhite.StateServer.State

  @type internal_state :: any()

  @type t :: %State{
          configuration: Configuration.t(),
          internal_state: internal_state(),
          pubsub_topic: any(),
          name: any(),
          module: module(),
          update_timer: reference() | :daily | nil
        }

  @type configuration :: Configuration.t()

  def init(args) do
    {name, args} = Keyword.pop!(args, :name)
    {pubsub_topic, args} = Keyword.pop!(args, :pubsub_topic)
    {module, args} = Keyword.pop!(args, :module)
    configuration = module.init_configuration(args)

    with {:ok, internal_state} <- module.init_state(args) do
      {:ok,
       %State{
         name: name,
         module: module,
         pubsub_topic: pubsub_topic,
         configuration: configuration,
         internal_state: internal_state
       }}
    end
  end

  def schedule_update(%State{update_timer: update_timer} = state, timer) do
    if is_reference(update_timer), do: Process.cancel_timer(update_timer)
    update_timer = Process.send_after(self(), {:"$state_server", :update}, timer)
    %State{state | update_timer: update_timer}
  end

  def schedule_update(
        %State{
          update_timer: current_update_timer,
          configuration: %Configuration{update_timer: {:schedule, time}}
        } = state
      ) do
    if is_nil(current_update_timer) or is_reference(current_update_timer) do
      Scheduler.schedule(__MODULE__, time, {self(), {:"$state_server", :update}})
      send(self(), {:"$state_server", :update})
      %State{state | update_timer: {:schedule, time}}
    else
      state
    end
  end

  def schedule_update(%State{configuration: %Configuration{update_timer: update_timer}} = state) do
    schedule_update(state, update_timer)
  end

  def put_internal_state(%State{} = state, internal_state) do
    %State{state | internal_state: internal_state}
  end

  def broadcast(%State{} = state, message) do
    send(self(), {:"$state_server", {:broadcast, message}})
    state
  end

  def invoke_handler(
        %State{module: module, internal_state: internal_state, configuration: configuration} =
          state,
        function
      ) do
    result =
      case function do
        {:handle_message, message} ->
          module.handle_message(message, internal_state, configuration)

        :handle_update ->
          module.handle_update(internal_state, configuration)

        {:handle_trigger, message} ->
          module.handle_get(message, internal_state, configuration)

        :handle_state_call ->
          module.handle_state_call(internal_state, configuration)

        {:handle_async, name, ref, result} ->
          module.handle_async(name, ref, result, internal_state, configuration)
      end

    update_state(function, state, result)
  end

  defp update_state(:handle_state_call, _state, result), do: result

  defp update_state(
         _result,
         %State{internal_state: internal_state} = state,
         {:ok, new_internal_state}
       ) do
    if internal_state != new_internal_state do
      state
      |> put_internal_state(new_internal_state)
      |> broadcast(:updated)
    else
      state
    end
  end

  defp update_state(_result, state, :ignore), do: state
  defp update_state(_result, state, {:error, _}), do: state
end
