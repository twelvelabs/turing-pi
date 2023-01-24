# Turing Pi

Scripts for setting up my Turing Pi V1 cluster. Compute module flashing config adapted from [the official docs](https://docs.turingpi.com).

![turing-pi](./docs/turing-pi.jpeg)

## Flashing Compute Modules

- Ensure dependencies are installed and download the [Raspberry Pi OS](https://www.raspberrypi.com/software/) image. This only needs to be done once.

  ```bash
  make setup
  make download
  ```

- Connect the Turing Pi to your laptop via a micro-USB to USB-C cable
- Insert a compute module into the first slot of the Turing Pi
- Power on the Turing Pi
- Run:

  ```bash
  # Env vars can be omitted; you will be prompted for input if they are missing.
  make flash SSID="My Wifi Network" PSK="my-wpa-password" CMID=1
  ```

- Repeat (incrementing the `$CMID` env var) until all compute modules have been flashed
