defmodule Snowhite.Helpers.Html do
  @doc """
  Helpers that creates a class using by a given set of predicates.

  It supports the following format:

  - `{function, true_class, false_class}`: if the function is true, the true_class is prepended, otherwise the false_class.
  - `{function, class}`: if the function is true, the class is prepended.
  - `function`: returns the result of the given function
  - `class`: always present

  ## Examples

  ```
  iex> conditions = [
    {fn user -> user.age > 18 end, "is-adult"},
    {fn user -> user.state == true end, "is-active", "is-inactive"},
    fn user -> if user.gender == :female, do: "is-female", else: "is-male" end,
    "user"
  ]
  iex> classes(conditions, [%{age: 20, active: true, gender: :female}])
  "user is-female is-active is-adult"
  iex> classes(conditions, [%{age: 10, active: true, gender: :male}])
  "user is-male is-active"
  iex> classes(conditions, [%{age: 10, active: false, gender: :female}])
  "user is-female is_inactive"
  ```
  """
  @type class() :: String.t()
  @type condition() :: {function(), class()}
  @type binary_condition() :: {function(), class(), class()}
  @type class_type() :: condition() | function() | class()
  @spec classes([class_type()], list()) :: String.t()
  def classes(conditions, args) do
    conditions
    |> Enum.reduce([], fn
      {func, true_class, false_class}, acc ->
        if apply(func, args), do: [true_class | acc], else: [false_class | acc]

      {func, class}, acc ->
        if apply(func, args), do: [class | acc], else: acc

      func, acc when is_function(func) ->
        [apply(func, args) | acc]

      class, acc ->
        [class | acc]
    end)
    |> Enum.join(" ")
  end
end
