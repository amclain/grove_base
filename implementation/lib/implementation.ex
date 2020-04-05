defmodule Implementation do
  @moduledoc """
  An implementation of GroveBase to use for testing
  when developing this library.
  """

  use GroveBase

  require Logger

  @impl true
  def handle_info(msg, state) do
    Logger.info("handle_info #{inspect(msg)}")

    {:noreply, state}
  end
end
