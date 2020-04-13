defmodule GroveBase do
  @moduledoc """
  A framework for using Seeed Studio's [Grove System](http://wiki.seeedstudio.com/Grove_System/),
  a standardized hardware prototyping system, with [Elixir](https://elixir-lang.org/)
  on embedded hardware with [Nerves](https://nerves-project.org/).

  Raspberry Pi:
  https://www.seeedstudio.com/Grove-Base-Hat-for-Raspberry-Pi.html

  BeagleBone:
  https://www.seeedstudio.com/Grove-Base-Cape-for-Beagleboner-v2-0.html
  """

  @doc """
  Returns the `:grove_base` configuration for the target platform,
  as specified in the project's `config.exs` file.
  """
  def config do
    Application.get_env(:grove_base, :io)[target()]
  end

  @doc """
  Returns the identifier for the target platform.

  Example: `:bbb` or `:rpi4`
  """
  def target do
    Application.get_env(:grove_base, :target)
  end

  defmacro __using__(_) do
    quote do
      use GenServer

      def start_link do
        GenServer.start(__MODULE__, nil)
      end

      @impl true
      def init(_) do
        config = GroveBase.config()

        i2c_path =
          case GroveBase.target() do
            :bbb -> "i2c-2"
            :rpi0 -> "i2c-1"
            :rpi4 -> "i2c-1"
          end

        {:ok, i2c_ref} = Circuits.I2C.open(i2c_path)

        adc_pids =
          config
          |> get_pins("adc")
          |> Enum.reduce(%{}, fn adc_number, acc ->
            adc_config = config[:"adc_#{adc_number}"]

            if adc_config do
              {:ok, adc_pid} =
                GroveBase.ADC.start_link(adc_number, self(),
                  sample_rate: adc_config[:sample_rate],
                  i2c_ref: i2c_ref
                )

              Map.put(acc, :"adc_#{adc_number}", adc_pid)
            else
              acc
            end
          end)

        gpio_pids =
          config
          |> get_pins("gpio")
          |> Enum.reduce(%{}, fn pin, acc ->
            pin_config = config[:"gpio_#{pin}"]

            if pin_config do
              direction = pin_config[:direction]
              interrupt = pin_config[:interrupt]

              unless direction, do: throw("Pin #{pin} :direction not set")

              opts =
                pin_config
                |> Keyword.delete(:direction)
                |> Keyword.delete(:interrupt)

              {:ok, gpio} = Circuits.GPIO.open(pin, direction, opts)

              if interrupt,
                do: Circuits.GPIO.set_interrupts(gpio, interrupt)

              Map.put(acc, :"gpio_#{pin}", gpio)
            else
              acc
            end
          end)

        {:ok,
         %{
           adc_pids: adc_pids,
           gpio_pids: gpio_pids,
           i2c_ref: i2c_ref
         }}
      end

      def gpio_write(pid, pin, value) do
        GenServer.call(pid, {:gpio_write, pin, value})
      end

      @impl true
      def handle_call({:gpio_write, pin, value}, _from, state) do
        gpio_pid = state.gpio_pids[:"gpio_#{pin}"]
        reply = Circuits.GPIO.write(gpio_pid, value)

        {:reply, reply, state}
      end

      defp get_pins(config, pin_prefix) do
        pin_prefix =
          case String.ends_with?(pin_prefix, "_") do
            true -> pin_prefix
            _ -> pin_prefix <> "_"
          end

        config
        |> Keyword.keys()
        |> Enum.filter(&(&1 |> Atom.to_string() |> String.starts_with?(pin_prefix)))
        |> Enum.map(
          &(&1
            |> Atom.to_string()
            |> String.trim_leading(pin_prefix)
            |> String.to_integer())
        )
      end
    end
  end
end
