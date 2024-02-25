//! Blinks the LED on a Pico board
//!
//! This will blink an LED attached to GP25, which is the pin the Pico uses for the on-board LED.
#![no_std]
#![no_main]

use bsp::entry;
use core::arch::global_asm;
use defmt::*;
use defmt_rtt as _;
use panic_probe as _;

// Provide an alias for our BSP so we can switch targets quickly.
// Uncomment the BSP you included in Cargo.toml, the rest of the code does not need to change.
use rp_pico as bsp;


use bsp::hal::{
    clocks::{init_clocks_and_plls, Clock},
    pac,
    watchdog::Watchdog,
};

global_asm!(include_str!("blink.S"));

extern "C" {
    fn xconfig_gpio();
    fn xled_on();
    fn xled_off();
    fn xreset_gpio();
}

fn reset_gpio() {
    unsafe {
        xreset_gpio();
    }
}

fn setup_gpio() {
    unsafe {
        xconfig_gpio();
    }
}
fn led_off() {
    unsafe {
        xled_off();
    }
}

fn led_on() {
    unsafe {
        xled_on();
    }
}

#[entry]
fn main() -> ! {
    info!("Program start");
    let mut pac = pac::Peripherals::take().unwrap();
    let core = pac::CorePeripherals::take().unwrap();
    let mut watchdog = Watchdog::new(pac.WATCHDOG);

    // External high-speed crystal on the pico board is 12Mhz
    let external_xtal_freq_hz = 12_000_000u32;
    let clocks = init_clocks_and_plls(
        external_xtal_freq_hz,
        pac.XOSC,
        pac.CLOCKS,
        pac.PLL_SYS,
        pac.PLL_USB,
        &mut pac.RESETS,
        &mut watchdog,
    )
    .ok()
    .unwrap();

    let mut delay = cortex_m::delay::Delay::new(core.SYST, clocks.system_clock.freq().to_Hz());

    reset_gpio();
    delay.delay_ms(100);
    info!("GPIO reset");

    setup_gpio();
    info!("GPIO initialized");
    delay.delay_ms(100);

    loop {
        info!("on!");
        led_on();

        delay.delay_ms(500);
        info!("off!");
        led_off();

        delay.delay_ms(500);
    }
}

// End of file
