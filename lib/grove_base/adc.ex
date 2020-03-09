defmodule GroveBase.ADC do
  @moduledoc """
  Interface with the onboard analog to digital converters.
  """

  use GenServer

  @bbb_base_path "/sys/bus/iio/devices/iio:device0"
  @rpi_adc_i2c_address 0x04
  @rpi_adc_base_address 0x10

  defmodule State do
    @moduledoc false
    defstruct [:adc_number, :i2c_ref, :notify_pid, :sample_rate, :timer_ref]
  end

  def start_link(adc_number, notify_pid, opts \\ []) do
    GenServer.start_link(__MODULE__, {adc_number, notify_pid, opts})
  end

  @impl true
  def init({adc_number, notify_pid, opts}) do
    i2c_ref = Keyword.get(opts, :i2c_ref)
    sample_rate = Keyword.get(opts, :sample_rate, 100)

    state = %State{
      adc_number: adc_number,
      i2c_ref: i2c_ref,
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
    value = read_adc(state)

    send(state.notify_pid, {:grove_adc, state.adc_number, value})

    timer_ref = Process.send_after(self(), :timer_tick, state.sample_rate)

    {:noreply, %State{state | timer_ref: timer_ref}}
  end

  defp read_adc(state) do
    case GroveBase.target() do
      :bbb -> read_bbb_adc(state)
      :rpi4 -> read_rpi4_adc(state)
    end
  end

  defp read_bbb_adc(state) do
    {:ok, string_value} =
      @bbb_base_path
      |> Path.join("in_voltage#{state.adc_number}_raw")
      |> File.read()

    string_value |> String.trim() |> String.to_integer()
  end

  defp read_rpi4_adc(state) do
    adc_address = <<@rpi_adc_base_address + state.adc_number>>

    {:ok, <<value::unsigned-little-integer-size(16)>>} =
      Circuits.I2C.write_read(state.i2c_ref, @rpi_adc_i2c_address, adc_address, 2)

    value
  end
end
