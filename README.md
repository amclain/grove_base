# GroveBase

[![Hex Version](https://img.shields.io/hexpm/v/grove_base.svg)](https://hex.pm/packages/grove_base)
[![API Documentation](http://img.shields.io/badge/docs-api-blue.svg)](https://hexdocs.pm/grove_base/)

A framework for using Seeed Studio's [Grove System](http://wiki.seeedstudio.com/Grove_System/), a standardized hardware prototyping system, with [Elixir](https://elixir-lang.org/) on embedded hardware with [Nerves](https://nerves-project.org/).

An example is located in [`/implementation`](implementation).

## Creating a new project

Create a new [Nerves app](https://hexdocs.pm/nerves/getting-started.html#creating-a-new-nerves-app).

In the project's `mix.exs` file, add GroveBase as a dependency for all targets. See [hex](https://hex.pm/packages/grove_base) for releases of this framework.

```ex
{:grove_base, "~> x.x.x"}
```

Add the appropriate [Nerves systems](https://hexdocs.pm/nerves/targets.html#supported-targets-and-systems) for the hardware platforms you intend to target. If targeting the BeagleBone, add `amclain/nerves_system_bbb_grove` instead of the stock Nerves system.

```ex
# Dependencies for specific targets
{:nerves_system_rpi0, "~> 1.11", runtime: false, targets: :rpi0},
{:nerves_system_rpi4, "~> 1.11", runtime: false, targets: :rpi4},
{:nerves_system_bbb_grove,
 github: "amclain/nerves_system_bbb_grove", tag: "v0.2.0", runtime: false, targets: :bbb}
```

In `/config/config.exs` add an import for the Grove config file:

```ex
if Mix.target() != :host do
  import_config "target.exs"
  import_config "grove.exs" # <-- Add this line
end
```

Create the file `/config/grove.exs`, which will configure Grove for your project. For reference, see [/implementation/config/grove.exs](implementation/config/grove.exs).

```ex
import Config

config :grove_base, target: Mix.target()

config :grove_base,
  io: [
    <target>: [
      # Configuration
      # ...
    ]
  ]

```

In your application code (`/lib`), create a module that is responsible for communication with the Grove hardware. For example, this could be your application's root module. Add `use GroveBase` to import the Grove functionality into this module. See [/implementation/lib/implementation.ex](implementation/lib/implementation.ex) for an example.

```ex
defmodule MyProject do
  use GroveBase

  # Project code...
end

```

GroveBase starts a [GenServer](https://hexdocs.pm/elixir/GenServer.html) under the hood, which will send messages to the module it is used in. These messages can be captured and acted on by creating [`handle_info`](https://hexdocs.pm/elixir/GenServer.html#c:handle_info/2) functions. GroveBase utilizes the [Circuits](https://elixir-circuits.github.io/) libraries and passes these events straight through as the `handle_info` `msg`.

```ex
defmodule MyProject do
  use GroveBase

  require Logger

  @impl true
  def handle_info(msg, state) do
    Logger.info("handle_info #{inspect(msg)}")

    {:noreply, state}
  end
end
```
