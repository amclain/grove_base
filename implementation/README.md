# GroveBase Implementation

An example implementation and integration testing for [GroveBase](../README.md).

## Usage

To start this module, run the following command in IEx:

```ex
{:ok, pid} = Implementation.start_link
```

To view event notifications as they're received:
```ex
RingLogger.attach
```
