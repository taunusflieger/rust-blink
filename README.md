# Demo for calling assembly code from Rust

This is a simple example of how to call assembly code from Rust. The assembly code is targeting the Raspberry Pico RP2040 microcontroller, but the principles are the same for any other architecture. The assembly code is used to toggle the GPIO pin 25 on the RP2040 which is connected to the onboard LED. The code shows how to initialize and reset the SIO and the PADs, and how to toggle the GPIO pin 25.

Of course, there are easier ways (through the HAL in Rust) to toggle the LED, but this is just a simple example to show how to call assembly code from Rust.