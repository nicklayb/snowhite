defmodule Snowhite.StateServer do
  @callback handle_update(map()) :: {:ok, map()} | {:error, any} | :ignore
  @callback handle_info(any(), map()) :: {:ok, map()} | :ignore
  @callback init_state(Keyword.t()) :: {:ok, map()} | :ignore

  defmacro __using__(options) do
    quote do
      use GenServer

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

      defdelegate init(args), to: Snowhite.StateServer
      defdelegate handle_info(message, state), to: Snowhite.StateServer
      defdelegate handle_call(message, relpy_to, state), to: Snowhite.StateServer
      defdelegate handle_cast(message, state), to: Snowhite.StateServer
    end
  end

  def start_link(args, options) do
    module = Keyword.fetch!(options, :module)
    name = Keyword.fetch!(options, :name)
    GenServer.start_link(module, Keyword.merge(args, name: name, module: module), name: name)
  end

  @init_timer :timer.seconds(1)
  @default_update_timer :timer.seconds(5)
  def init(args) do
    name = Keyword.fetch!(args, :name)
    module = Keyword.fetch!(args, :module)
    update_timer = Keyword.get(args, :update_timer, @default_update_timer)

    with {:ok, internal_state} <- module.init_state(args) do
      state =
        %{name: name, module: module, internal_state: internal_state, update_timer: update_timer}

      {:ok, schedule_update(state, @init_timer)}
    end
  end

  def handle_info(
        {:"$state_server", :update},
        %{internal_state: internal_state, module: module} = state
      ) do
    new_internal_state =
      case module.handle_update(internal_state) do
        {:ok, new_internal_state} ->
          broadcast(new_internal_state, :update)

        {:error, _error} ->
          internal_state

        :ignore ->
          internal_state
      end

    state =
      state
      |> put_internal_state(new_internal_state)
      |> schedule_update()

    {:noreply, state}
  end

  def handle_info(
        {:"$state_server", {:broadcast, message}},
        %{pubsub_topic: pubsub_topic, internal_state: internal_state} = state
      ) do
    Phoenix.PubSub.broadcast!(Snowhite.PubSub, pubsub_topic, {message, internal_state})
    {:noreply, state}
  end

  def handle_info(message, %{module: module, internal_state: internal_state} = state) do
    new_internal_state =
      case module.handle_info(message, internal_state) do
        {:ok, new_internal_state} -> new_internal_state
        :ignore -> internal_state
      end

    {:noreply, put_internal_state(state, new_internal_state)}
  end

  defp schedule_update(state, timer) do
    Process.send_after(self(), {:"$state_server", :update}, timer)
    state
  end

  defp schedule_update(%{update_timer: update_timer} = state) do
    schedule_update(state, update_timer)
  end

  defp put_internal_state(state, internal_state) do
    %{state | internal_state: internal_state}
  end

  defp broadcast(state, message) do
    send(self(), {:"$state_server", {:broadcast, message}})
    state
  end
end
