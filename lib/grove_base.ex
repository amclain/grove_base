defmodule GroveBase do
  @moduledoc """
  Nerves support for the Seeed Studio Grove base.

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

  Example: `:bbb` or `:rpi`
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

      if Mix.target() == :bbb do
        @doc false
        def init(_) do
          config = GroveBase.config()

          gpio_pids =
            [50, 51, 115, 117]
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
             gpio_pids: gpio_pids
           }}
        end
      end

      if Mix.target() == :rpi do
        @doc false
        def init(_) do
          throw("TODO: Support Raspberry Pi")

          {:ok, nil}
        end
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
    end
  end
end
