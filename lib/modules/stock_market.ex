defmodule Snowhite.Modules.StockMarket do
  use Snowhite.Builder.Module
  import Snowhite.Builder.Module
  alias __MODULE__
  alias __MODULE__.Symbol

  def mount(socket) do
    send(self(), :updated)
    socket = assign(socket, :prices, [])
    {:ok, socket}
  end

  def module_options do
    %{
      symbols: :required,
      adapter: {:optional, StockMarket.Adapters.Finnhub},
      adapter_options: {:optional, []},
      timezone: {:optional, "UTC"}
    }
  end

  def render(assigns) do
    ~L"""
      <div class="wrapper">
        <%= for {_, %Symbol{symbol: symbol, value: value, change: change}} <- @prices do %>
          <div class="symbol symbol-<%= color(change) %>">
            <h1><%= symbol %></h1>
            <h2 class="value"><%= Float.round(value, 2) %> </h2>
            <h2 class="change"><%= Float.round(change, 2) %> </h2>
          </div>
        <% end %>
      </div>
    """
  end

  defp color(value) when value > 0, do: "positive"
  defp color(value) when value < 0, do: "negative"
  defp color(_value), do: "even"

  def handle_info(:updated, socket) do
    prices = StockMarket.Server.prices()
    socket = assign(socket, :prices, prices)
    {:noreply, socket}
  end

  def applications(options) do
    [
      {StockMarket.Server, options}
    ]
  end
end
