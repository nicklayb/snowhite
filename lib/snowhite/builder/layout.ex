defmodule Snowhite.Builder.Layout do
  alias __MODULE__
  @positions ~w(
    top_left    top_center    top_right
    middle_left middle_center middle_right
    bottom_left bottom_center bottom_right
  )a
  alias Snowhite.Helpers.Map, as: MapHelpers

  @type t :: %Layout{}
  @type position ::
          :top_left
          | :top_center
          | :top_right
          | :middle_left
          | :middle_center
          | :middle_right
          | :bottom_left
          | :bottom_center
          | :bottom_right
  @type module_definition :: {atom(), keyword()}
  defstruct Enum.map(@positions, &{&1, []})

  @spec positions :: [position()]
  def positions, do: @positions

  @spec modules(t()) :: [module_definition()]
  def modules(%Layout{} = layout) do
    Enum.flat_map(@positions, &Map.get(layout, &1, []))
  end

  @spec put_module(t(), position(), module_definition()) :: t()
  def put_module(%Layout{} = layout, position, module) do
    MapHelpers.append(layout, position, module)
  end
end
