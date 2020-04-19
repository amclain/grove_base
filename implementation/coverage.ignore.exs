defmodule Implementation.Coverage do
  @moduledoc """
  Code coverage helpers
  """

  @doc """
  A list of modules to ignore when code coverage runs.
  """
  def ignore_modules do
    [
      Implementation.Application
    ]
  end
end
