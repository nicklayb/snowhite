defmodule Snowhite.Builder.Module do
  @moduledoc """
  The module builder is the one responsible for building modules. It's basically a wrapper over Phoenix's LiveView but with some extra sugar.

  It is meant to provide a simple way to declare new modules and interact with server. It automatically assigns default assign (`params` and `options`) to your socket and support some extra features such as timed callbacks.

  By convention it is highly recommended to scope you modules under `Snowhite.Modules.*` to avoid collision with other existing modules.

  ## Mounting

  Most of the time, your module will have some extra assigns coming from either computed values or a Server. These has to be defined at **mount** of the module. To do so, all you need to do is override the `mount/1` function and perform your assignations.

  ### Examples

  ```elixir
  defmodule Snowhite.Modules.MyModule do
    use Snowhite.Builder.Module

    def mount(socket) do
      assign(socket, :message, "Hello world!") # Only has to return the updated socket,
    end
  end
  ```

  Assign `@message` will now be available in templates. At mount time, it's also important to note that the module will subscribe to Snowhite's PubSub under a topic matching is module name. For instance `Snowhite.Modules.Clock` subscribes on `"snowhite:modules:clock"`

  ## Module options

  To make sure you pass in the good options to a module, it is required that you declared them by overriding `module_options/0`. It follows a simple pattern of `[{option_name, type}]` where type is either `:required` or `{:optional, fallback}`.keyword()

  This has three advantages. It raises if you miss a required option, it raises if you add an unsupported option and put in a fallback if you omit an optional option.

  For instance, for weather modules, the city_id is required as you can't have the weather of a place you don't know. But you also might want to set the locale to "fr" if you wish to, but otherwise, english should do the job.


  ### Examples

  ```elixir
  defmodule Snowhite.Modules.MyModule do
    use Snowhite.Builder.Module

    def module_options do
      [
        message: :required, # it requires a message
        color: {:optional, :white} # it can be of any color but defaults to white
      ]
    end
  end
  ```

  ## Extra applications

  The best way to keep data consistent around multiple Snowhite pages, is to have them centralized in a GenServer or another type of Server. This is where extra applications comes in handy.

  ### Examples use case

  Before moving to `Snowhite.Modules.Clock.Server`, the clock was handled by the Live view itself. Even though it works, it has flaws. The clocks were not in sync since the pages weren't open at the exact same time. So we decided to use a Server.

  The `Snowhite.Modules.Clock.Server` is responsible for controlling clock in an atomic way. When it gets updated, it broadcasts an event so every pages updates at the exact same time. All default modules includes this concept, it might be interesting to take a look at those for inspiration.

  ### Examples

  ```elixir
  defmodule Snowhite.Modules.MyModule do
    use Snowhite.Builder.Module

    def applications(options) do # applications/1 receives options of the module for the application supervision
      [
        {Snowhite.Modules.MyModule.Server, []} # They are declared as {module, args}.
      ]
    end
  end
  ```

  By now, every Server is uniquely launched. It is sufficient for most use case, however, this would prevent you to have, for instance, multiple weather.

  ## Accessing module's config

  The builder also includes convenient functions to reach module's config when it is needed. For instance, to use the weather you need an API key for OpenWeather. As this value **should not** be commited, it's better to have it in an env variable.

  You can register it that way
  ```elixir
  config :snowhite, :modules,
    my_module: [
      api_key: System.get_env("SOME_API_KEY")
    ]

  # In your module
  defmodule Snowhite.Modules.MyModule do
    use Snowhite.Builder.Module

    def mount(socket) do
      assign(socket, :api_key, config(:api_key))
    end
  end
  ```
  **Note**: It is not required to have the config put in the assign, this is just an example on how to use the config/1 function.
  """
  alias Snowhite.Helpers.Casing
  alias Snowhite.Scheduler
  import Phoenix.LiveView

  @doc """
  The builder macro supports the following options

  - `:config_key`, key to use when fetching configs. Fallbacks to the modules name (`MyModule` -> `my_module`)
  - `:topic`, the topic to register on Snowhite's PubSub, it fallbacks to `snowhite:modules:my_module`
  """
  @type builder_option() :: {:config_key, atom()} | {:topic, String.t()}
  @spec __using__([builder_option()]) :: Macro.t()
  defmacro __using__(options) do
    config_key = Keyword.get(options, :config_key, nil)
    topic = Keyword.get(options, :topic, nil)

    quote do
      use Phoenix.LiveView
      import Snowhite.Builder.Module
      import Snowhite.Helpers.Timing
      import Snowhite.Helpers.Html
      alias Snowhite.Helpers.List, as: ListHelpers
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

  @doc """
  The `every/3` macro comes in handy when you want to perform action every x ms.

  It either supports an integer (for a given amount of seconds, it is recommended to use the `~d()` sigil from `Snowhite.Helpers.Timing` to inscrease readability) or an atom to get the amount of ms from the options. It also needs an unique name so every callbacks has it's own name and a function to be called.

  ## Examples

  ```elixir
  defmodule Snowhite.Modules.MyModule do
    use Snowhite.Builder.Module # Imports the ~d sigil by default

    every(~d(1m), :count, &count/1)

    def count(socket) do # called every minutes
      assign(sockey, :counter, socket.assigns.counter + 1)
    end
  end
  ```
  """
  @spec every(non_neg_integer() | atom(), atom(), function()) :: Macro.t()
  defmacro every(ms, name, func) do
    quote do
      @scheduled [unquote(name) | @scheduled]

      cond do
        is_atom(unquote(ms)) ->
          def event_timing(unquote(name), socket), do: get_option(socket, unquote(ms))

        is_integer(unquote(ms)) ->
          def event_timing(unquote(name), _socket), do: unquote(ms)
      end

      def handle_info(unquote(name), socket) do
        socket = unquote(func).(socket)

        ms = event_timing(unquote(name), socket)

        Process.send_after(self(), unquote(name), ms)

        {:noreply, socket}
      end
    end
  end

  @doc """
  This macro is required as it will make scheduled events from `every/3` working.
  """
  defmacro __before_compile__(_) do
    quote do
      def scheduled_events, do: @scheduled

      def run_scheduled_events do
        Enum.each(scheduled_events(), &send(self(), &1))
      end
    end
  end

  @doc """
  Same as `get_options/3` but with `nil` as fallback value
  """
  @spec get_option(Phoenix.Socket.t() | %{options: keyword()}, atom()) :: any()
  def get_option(socket, key), do: get_option(socket, key, nil)

  @doc """
  Get an option from the assigns or the socket with an optional fallback. As the options are matched against your module options, the default value should be the one declared in `module_options/0`.
  """
  @spec get_option(Phoenix.Socket.t() | %{options: keyword()}, atom(), any()) :: any()
  def get_option(%{assigns: assigns}, key, fallback),
    do: get_option(assigns, key, fallback)

  def get_option(%{options: options}, key, fallback) do
    Keyword.get(options, key, fallback)
  end

  @doc """
  Sets default assign in a module. The templates is rendered with the request params so you can use them in you Modules. Same for options that you pass when declaring a module.
  """
  @spec assign_session(Phoenix.LiveView.Socket.t(), map) :: Phoenix.LiveView.Socket.t()
  def assign_session(socket, %{"options" => options, "params" => params}) do
    socket
    |> assign(:options, options)
    |> assign(:params, params)
  end

  @doc """
  Gets a configuration key for a specific module. By default, any module registers it's configuration under `snowhite.modules.[module_name]`.

  i.e. For the `Snowhite.Modules.Clock` module, it's configuration key is `:clock` so you can configure it that way
  ```elixir
  config :snowhite, :modules, clock: [format: ""]
  ```
  """
  @spec module_config(atom(), atom(), any()) :: any()
  def module_config(config_key, value, fallback \\ nil) do
    :snowhite
    |> Application.get_env(:modules)
    |> Keyword.get(config_key, [])
    |> Keyword.get(value, fallback)
  end

  @doc """
  Broadcasts an event on the Snowhite's PubSub server. All modules subscribes on it so they can communicate with each other.
  """
  @spec broadcast(String.t(), any) :: :ok | {:error, any}
  def broadcast(topic, event) do
    Phoenix.PubSub.broadcast(Snowhite.PubSub, topic, event)
  end
end
