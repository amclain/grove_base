defmodule GroveBase.ADC do
  @moduledoc """
  Interface with the onboard analog to digital converters.
  """

  use GenServer

  @base_path "/sys/bus/iio/devices/iio:device0"

  defmodule State do
    @moduledoc false
    defstruct [:adc_number, :notify_pid, :sample_rate, :timer_ref]
  end

  def start_link(adc_number, notify_pid, opts \\ []) do
    GenServer.start_link(__MODULE__, {adc_number, notify_pid, opts})
  end

  @impl true
  def init({adc_number, notify_pid, opts}) do
    sample_rate = Keyword.get(opts, :sample_rate, 100)

    state = %State{
      adc_number: adc_number,
      notify_pid: notify_pid,
      sample_rate: sample_rate
    }

    {:ok, state, {:continue, :init}}
  end

  @impl true
  def handle_continue(:init, state) do
    timer_ref = Process.send_after(self(), :timer_tick, state.sample_rate)

    {:noreply, %State{state | timer_ref: timer_ref}}
  end

  @impl true
  def handle_info(:timer_tick, state) do
    {:ok, string_value} =
      @base_path
      |> Path.join("in_voltage#{state.adc_number}_raw")
      |> File.read()

    value = string_value |> String.trim() |> String.to_integer()

    send(state.notify_pid, {:grove_adc, state.adc_number, value})

    timer_ref = Process.send_after(self(), :timer_tick, state.sample_rate)

    {:noreply, %State{state | timer_ref: timer_ref}}
  end
end
