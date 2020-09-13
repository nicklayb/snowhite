defmodule Snowhite.Builder.Layout do
  @moduledoc """
  Represents modules disposition on a 3 by 3 layout. Modules are registered as {module, args}.
  """
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

  @doc """
  Gets a all possible positions which are #{Enum.join(@positions, ", ")}
  """
  @spec positions :: [position()]
  def positions, do: @positions

  @doc """
  Gets all layout's modules without their positions
  """
  @spec modules(t()) :: [module_definition()]
  def modules(%Layout{} = layout) do
    Enum.flat_map(positions(), &Map.get(layout, &1, []))
  end

  @doc """
  Puts a module in a given layout in the right position. This is the main function used for building layouts
  """
  @spec put_module(t(), position(), module_definition()) :: t()
  def put_module(%Layout{} = layout, position, module) do
    if position not in @positions, do: raise(ArgumentError, "Invalid #{position} position")
    MapHelpers.append(layout, position, module)
  end
end
