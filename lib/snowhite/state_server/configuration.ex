defmodule Snowhite.StateServer.Configuration do
  defstruct [:update_timer, options: %{}]

  alias Snowhite.StateServer.Configuration

  @type t :: %Configuration{
          update_timer: non_neg_integer() | nil,
          options: map()
        }
end
