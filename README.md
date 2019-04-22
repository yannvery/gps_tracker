# GpsTracker

A GPS tracker builds with nerves project.

## Installation

```
mix compile
NERVES_NETWORK_SSID=my_network NERVES_NETWORK_PSK=secret MIX_TARGET=rpi3 mix firmware
MIX_TARGET=rpi3 mix firmware.burn
```

