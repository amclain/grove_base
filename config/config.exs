# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
import Config

config :grove_base, target: Mix.target()

# Customize non-Elixir parts of the firmware. See
# https://hexdocs.pm/nerves/advanced-configuration.html for details.

config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

# Set the SOURCE_DATE_EPOCH date for reproducible builds.
# See https://reproducible-builds.org/docs/source-date-epoch/ for more information

config :nerves, source_date_epoch: "1583106025"

# Use Ringlogger as the logger backend and remove :console.
# See https://hexdocs.pm/ring_logger/readme.html for more information on
# configuring ring_logger.

config :logger, backends: [RingLogger]

if Mix.target() != :host do
  import_config "target.exs"
end

config :grove_base,
  io: %{
    bbb: [
      adc_0: [sample_rate: 1000],
      adc_1: [sample_rate: 1000],
      adc_2: [sample_rate: 1000],
      adc_3: [sample_rate: 1000],
      gpio_50: [direction: :input, interrupt: :both],
      gpio_51: [direction: :input, interrupt: :both],
      gpio_115: [direction: :output],
      gpio_117: [direction: :input, interrupt: :both],
      uart_1: [speed: 115_200],
      uart_4: [speed: 115_200]
    ],
    rpi4: [
      adc_0: [sample_rate: 1000],
      adc_1: [sample_rate: 1000],
      adc_2: [sample_rate: 1000],
      adc_3: [sample_rate: 1000],
      adc_4: [sample_rate: 1000],
      adc_5: [sample_rate: 1000],
      adc_6: [sample_rate: 1000],
      adc_7: [sample_rate: 1000],
      gpio_5: [direction: :input, interrupt: :both],
      gpio_6: [direction: :input, interrupt: :both],
      gpio_12: [direction: :input, interrupt: :both],
      gpio_13: [direction: :input, interrupt: :both],
      gpio_16: [direction: :output],
      gpio_17: [direction: :input, interrupt: :both],
      gpio_18: [direction: :input, interrupt: :both],
      gpio_19: [direction: :input, interrupt: :both],
      gpio_22: [direction: :input, interrupt: :both],
      gpio_23: [direction: :input, interrupt: :both],
      gpio_24: [direction: :input, interrupt: :both],
      gpio_25: [direction: :input, interrupt: :both],
      gpio_26: [direction: :input, interrupt: :both],
      gpio_27: [direction: :input, interrupt: :both],
      uart: [speed: 115_200]
    ]
  }
