defmodule Snowhite.Builder.Layout do
  alias __MODULE__
  @positions ~w(
    top_left    top_center    top_right
    middle_left middle_center middle_right
    bottom_left bottom_center bottom_right
  )a

  defstruct Enum.map(@positions, &{&1, []})

  def positions, do: @positions

  def modules(%Layout{} = layout) do
    Enum.flat_map(@positions, &Map.get(layout, &1, []))
  end
end
