import Config

config :grove_base, target: Mix.target()

rpi = [
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

config :grove_base,
  io: [
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
    rpi0: rpi,
    rpi4: rpi
  ]
