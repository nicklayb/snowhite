defmodule Snowhite.Builder.Module do
  alias Snowhite.Helpers.Casing
  import Phoenix.LiveView

  defmacro __using__(options) do
    config_key = Keyword.get(options, :config_key, nil)
    topic = Keyword.get(options, :topic, nil)

    quote do
      use Phoenix.LiveView
      import Snowhite.Builder.Module
      import Snowhite.Helpers.Timing
      import Snowhite.Helpers.Html
      @scheduled []
      @before_compile {Snowhite.Builder.Module, :__before_compile__}

      if is_nil(unquote(topic)) do
        @topic Casing.topic(__MODULE__)
      else
        @topic unquote(topic)
      end

      def mount(_, session, socket) do
        socket =
          socket
          |> assign_session(session)
          |> mount()

        run_scheduled_events()

        Phoenix.PubSub.subscribe(Snowhite.PubSub, @topic)

        socket
      end

      def mount(socket), do: socket

      if is_nil(unquote(config_key)) do
        def config_key, do: Casing.config_key(__MODULE__)
      else
        def config_key, do: unquote(config_key)
      end

      def config(key, fallback \\ nil), do: module_config(config_key(), key, fallback)

      def applications(_options), do: []

      def module_options, do: []

      defoverridable(mount: 1, applications: 1, module_options: 0)
    end
  end

  defmacro every(ms, name, block) do
    quote do
      @scheduled [unquote(name) | @scheduled]

      cond do
        is_atom(unquote(ms)) ->
          def event_timing(unquote(name), socket) do
            get_option(socket, unquote(ms))
          end

        is_integer(unquote(ms)) ->
          def event_timing(unquote(name), _socket) do
            unquote(ms)
          end
      end

      def handle_info(unquote(name), socket) do
        socket = unquote(block).(socket)

        ms = event_timing(unquote(name), socket)

        Process.send_after(self(), unquote(name), ms)

        {:noreply, socket}
      end
    end
  end

  defmacro __before_compile__(_) do
    quote do
      def scheduled_events, do: @scheduled

      def run_scheduled_events do
        Enum.each(scheduled_events(), &send(self(), &1))
      end
    end
  end

  def get_option(socket, key), do: get_option(socket, key, nil)

  def get_option(%{assigns: assigns}, key, fallback),
    do: get_option(assigns, key, fallback)

  def get_option(%{options: options}, key, fallback) do
    Keyword.get(options, key, fallback)
  end

  @spec put_option(Phoenix.LiveView.Socket.t(), atom(), any) :: Phoenix.LiveView.Socket.t()
  def put_option(%{assigns: %{options: options}} = socket, key, value) do
    options = Keyword.put(options, key, value)
    assign(socket, :options, options)
  end

  @spec assign_session(Phoenix.LiveView.Socket.t(), map) :: Phoenix.LiveView.Socket.t()
  def assign_session(socket, %{"options" => options, "params" => params}) do
    socket
    |> assign(:options, options)
    |> assign(:params, params)
  end

  def module_config(config_key, value, fallback \\ nil) do
    :snowhite
    |> Application.get_env(:modules)
    |> Keyword.get(config_key, [])
    |> Keyword.get(value, fallback)
  end

  def broadcast(topic, event) do
    Phoenix.PubSub.broadcast(Snowhite.PubSub, topic, event)
  end
end
