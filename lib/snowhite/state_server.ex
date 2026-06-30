defmodule Snowhite.StateServer do
  @moduledoc """
  State servers are GenServer holding a state and notifying on changes. It just does some specific things
  differently from a genserver like auto broadcasting on changes.

  ## Internal state

  State server wraps the module's state inside another server's state to
  track changes and notify on changes.

  The internal state will contain client's data but can also contain stuff for the server
  itself. If you would want to hide this, you can alter what the clients are receiving by
  overriding `handle_state_call/3`.
  """
  @behaviour GenServer
  alias Snowhite.StateServer.State

  require Logger

  @type internal_state :: State.internal_state()
  @type configuration :: State.configuration()

  @type success ::
          {:ok, internal_state()}
          | {:ok, internal_state(), configuration()}

  @doc "Inits the internal state. Make sure to provide an empty initial state the client can handle."
  @callback init_state(Keyword.t()) :: {:ok, internal_state()} | :ignore

  @doc "Inits the configuration, this is where you set the refresh time for auto reloading modules"
  @callback init_configuration(Keyword.t()) :: configuration()

  @doc "Handles an update trigger. This should call whatever external services in order to update its internal state"
  @callback handle_update(internal_state(), configuration()) ::
              success()
              | {:error, any}
              | :ignore

  @doc "Handles any incoming messages, mostly used for inter-process communication"
  @callback handle_message(any(), internal_state(), configuration()) :: success() | :ignore

  @doc "Handles an async update, this mechanism can provide parallelism inside of the server when multiple calls are necessary."
  @callback handle_async(any(), reference(), any(), internal_state(), configuration()) ::
              success() | :ignore

  @doc "Handles a 'trigger' call, which is a simple `cast` call."
  @callback handle_trigger(any(), internal_state(), configuration()) :: success() | :ignore

  @doc "Handles a state call, how you want your internal state to be exposed to clients."
  @callback handle_state_call(internal_state(), configuration()) :: any()

  defmacro __using__(options) do
    quote do
      use GenServer

      import Snowhite.StateServer
      import Snowhite.Helpers.Timing
      @behaviour Snowhite.StateServer

      options = unquote(options)
      @pubsub_topic Keyword.fetch!(options, :pubsub_topic)

      def start_link(args) do
        args
        |> Keyword.put_new(:pubsub_topic, @pubsub_topic)
        |> Snowhite.StateServer.start_link(
          name: Keyword.get(args, :name, __MODULE__),
          module: __MODULE__
        )
      end

      def get(pid \\ __MODULE__, key), do: GenServer.call(pid, {:"$state_server", :get, key})

      def state(pid \\ __MODULE__), do: GenServer.call(pid, {:"$state_server", :state})

      def trigger(pid \\ __MODULE__, message),
        do: GenServer.cast(pid, {:"$state_server", :trigger, message})

      def handle_message(_message, _state, _configuration), do: :ignore

      def handle_trigger(_message, _state, _configuration), do: :ignore

      def handle_async(_ref, _name, _result, _state, _configuration), do: :ignore

      def handle_state_call(internal_state, _configuration), do: internal_state

      @impl GenServer
      defdelegate init(args), to: Snowhite.StateServer
      @impl GenServer
      defdelegate handle_info(message, state), to: Snowhite.StateServer
      @impl GenServer
      defdelegate handle_cast(message, state), to: Snowhite.StateServer
      @impl GenServer
      defdelegate handle_call(message, reply_to, state), to: Snowhite.StateServer

      defoverridable(handle_message: 3, handle_trigger: 3, handle_async: 5, handle_state_call: 2)
    end
  end

  def start_link(args, options) do
    module = Keyword.fetch!(options, :module)
    name = Keyword.fetch!(options, :name)
    GenServer.start_link(module, Keyword.merge(args, name: name, module: module), name: name)
  end

  @init_timer :timer.seconds(1)
  @impl GenServer
  def init(args) do
    with {:ok, %State{} = state} <- State.init(args) do
      Process.flag(:trap_exit, true)
      {:ok, State.schedule_update(state, @init_timer)}
    end
  end

  @impl GenServer
  def handle_info({:"$state_server", :update}, %State{} = state) do
    new_state = State.invoke_handler(state, :handle_update)

    {:noreply, State.schedule_update(new_state)}
  end

  def handle_info(
        {:"$state_server", {:broadcast, message}},
        %State{pubsub_topic: pubsub_topic} = state
      ) do
    return = State.invoke_handler(state, :handle_state_call)
    Phoenix.PubSub.broadcast!(Snowhite.PubSub, pubsub_topic, {message, return})
    {:noreply, state}
  end

  def handle_info({:"$state_server", {:async, name, ref, result}}, state) do
    new_state = State.invoke_handler(state, {:handle_async, name, ref, result})
    {:noreply, new_state}
  end

  def handle_info({:EXIT, pid, reason, _}, %State{} = state) do
    Logger.error("[#{inspect(state.module)}] [exit] [#{inspect(pid)}] #{inspect(reason)}")
  end

  def handle_info(message, %State{} = state) do
    new_state = State.invoke_handler(state, {:handle_message, message})
    {:noreply, new_state}
  end

  @impl GenServer
  def handle_call({:"$state_server", :state}, _reply_to, %State{} = state) do
    return = State.invoke_handler(state, :handle_state_call)
    {:reply, return, state}
  end

  @impl GenServer
  def handle_cast({:"$state_server", :trigger, message}, %State{} = state) do
    new_state = State.invoke_handler(state, {:handle_trigger, message})

    {:noreply, new_state}
  end

  def async(state, name, function) do
    parent = self()
    ref = make_ref()

    pid =
      spawn_link(fn ->
        result = function.(state)
        send(parent, {:"$state_server", {:async, name, ref, result}})
      end)

    {pid, ref}
  end

  def options_to_state(state, module, options) when is_atom(module) do
    options_to_state(state, module.module_options(), options)
  end

  def options_to_state(state, module_options, provided_options)
      when is_map(module_options) do
    Enum.reduce(module_options, state, fn
      {key, :required}, acc ->
        Map.put(acc, key, Keyword.fetch!(provided_options, key))

      {key, {:optional, default}}, acc ->
        Map.put(acc, key, Keyword.get(provided_options, key, default))
    end)
  end
end
