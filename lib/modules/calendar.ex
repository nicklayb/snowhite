defmodule Snowhite.Modules.Calendar do
  use Snowhite.Builder.Module, topic: "snowhite:modules:clock"
  import Snowhite.Builder.Module
  alias Snowhite.Modules.Clock
  alias Snowhite.Helpers.CalendarBuilder

  def mount(socket) do
    {:ok, set_current_date(socket)}
  end

  def module_options do
    %{
      locale: {:optional, "en"},
      timezone: {:optional, "UTC"}
    }
  end

  @weekdays [
    ~D[2020-11-01],
    ~D[2020-11-02],
    ~D[2020-11-03],
    ~D[2020-11-04],
    ~D[2020-11-05],
    ~D[2020-11-06],
    ~D[2020-11-07]
  ]
  def render(assigns) do
    weekdays = @weekdays

    ~H"""
      <div>
        <table>
          <thead>
            <tr>
              <%= for weekday <- weekdays do %>
                <th>
                  <%= day_letter(weekday, assigns) %>
                </th>
              <% end %>
            </tr>
          </thead>
          <tbody>
            <%= for week <- @calendar do %>
              <tr>
                <%= for day <- week do %>
                <td class={cell_classes(@current_date, day)}>
                  <%= day.day %>
                </td>
                <% end %>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    """
  end

  defp cell_classes(current_date, date) do
    classes(
      [
        {&is_weekend?/2, "weekend"},
        {&is_today?/2, "today"},
        {&other_month?/2, "other-month"}
      ],
      [current_date, date]
    )
  end

  defp day_letter(date, assigns) do
    date
    |> Timex.lformat!("{WDshort}", get_option(assigns, :locale))
    |> String.at(0)
    |> String.upcase()
  end

  @weekend [6, 7]
  defp is_weekend?(_, date), do: Timex.weekday(date) in @weekend

  defp is_today?(current, date), do: current == date

  defp other_month?(%{month: current_month}, %{month: month}), do: month != current_month

  def handle_info(:updated, socket) do
    {:noreply, set_current_date(socket)}
  end

  defp set_current_date(%{assigns: assigns} = socket) do
    current_date = Map.get(assigns, :current_date, nil)
    new_date = Clock.Server.date()

    if current_date == new_date do
      socket
    else
      socket
      |> assign(:current_date, new_date)
      |> assign(:calendar, CalendarBuilder.build_month(new_date))
    end
  end

  def applications(options) do
    [
      {Clock.Server, options}
    ]
  end
end
