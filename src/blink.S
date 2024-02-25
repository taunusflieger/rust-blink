// APB Peripheral base
.set APB_BASE_ADDR, 0x40000000

// Reset controller registers base
.set RESETS_BASE_ADDR,(APB_BASE_ADDR + 0xc000)
.set RESETS_CTRL, (RESETS_BASE_ADDR + 0x0)
.set RESETS_PADS_BANK0, (1 << 8)
.set RESETS_IO_BANK0, (1 << 5)
.set RESETS_DONE, (RESETS_BASE_ADDR + 0x8)

// IO bank 0 base address
.set IO_BANK0_BASE, (APB_BASE_ADDR + 0x14000)

// On a Raspberry Pi Pico the 25th pin is connected to an led.
// GPIO pin 25 control register.
.set GPIO_25_CTRL_OFFSET, 0x0cc
.set GPIO_25_CTRL,(IO_BANK0_BASE + GPIO_25_CTRL_OFFSET)

// Each GPIO pin can be configured to serve different purposes: UART, I2C, SIO etc.
// Software I/O is function number 5
.set GPIO_FUNCSEL_SIO, 5

// PADs are the input / output driver for the GPIO pins. They need
// to configures for output
//Base address for PADS bank 0
.set PADS_BANK0_BASE, (APB_BASE_ADDR + 0x1c00)

// Pad control register for GPIO 25
.set GPIO_25_PAD_CTRL_OFFSET, 0x68
.set GPIO_25_PAD_CTRL_ADR, (PADS_BANK0_BASE + GPIO_25_PAD_CTRL_OFFSET)

// Output enable, pull-up for for GPIO 25
.set GPIO_25_PAD_CONFIG, 0x00

// SIO = Software Input/Output, used for controlling GPIO output and input
// Base address of peripheral.
.set SIO_BASE_ADDR, 0xd0000000

// SIO Output register offset.
.set SIO_OUTPUT_OFFSET, 0x10
.set GPIO_OUT_ADR, (SIO_BASE_ADDR + SIO_OUTPUT_OFFSET)

// GPIO output enable set
.set GPIO_OUT_SET_OFFSET, 0x24
.set GPIO_OUT_SET_ADR, (SIO_BASE_ADDR + GPIO_OUT_SET_OFFSET)

// Mask GPIO_x for direct control of IO bank 0 (user GPIOs 0 to 29, starting at the LSB)
.set SIO_GPIO_25_MASK, 1 << 25

.cpu cortex-m0plus
.thumb

.global xreset_gpio
.thumb_func
xreset_gpio:
    // *****************************************************
    // Reset PADs bank 0 and IO bank 0
    // *****************************************************
    push {{r0-r7, lr}}
	// take RESETS_PADS_BANK0 and RESETS_IO_BANK0 out of reset
	ldr r1, =RESETS_CTRL
	ldr r0, [r1]
	ldr r2, =(RESETS_PADS_BANK0 | RESETS_IO_BANK0)
	bics r0, r0, r2
	str r0, [r1]

unreset_check_loop:
	ldr r1, =RESETS_DONE
	ldr r0, [r1]
	tst r0, r2
	beq unreset_check_loop

    pop {{r0-r7, pc}}

.global xconfig_gpio
.thumb_func
xconfig_gpio:
    // *****************************************************
    // Configure GPIO pin 25 to drive the LED
    // *****************************************************
    push    {{r0-r7, lr}}
    // Configure GPIO 25 pin to be driven by SIO
    ldr r0, =GPIO_FUNCSEL_SIO
    ldr r1, =GPIO_25_CTRL
    str r0, [r1]
    // Configure the PAD for GPIO as output
    ldr r0, =GPIO_25_PAD_CONFIG
    ldr r1, =GPIO_25_PAD_CTRL_ADR
    str r0, [r1]
    // Enable SIO output for GPIO 25
    ldr r0, =SIO_GPIO_25_MASK
    ldr r1, =GPIO_OUT_SET_ADR
    str r0, [r1]

    pop     {{r0-r7, pc}}

.global xled_on
.thumb_func
xled_on:
    // *****************************************************
    // Turn the LED on
    // *****************************************************
    push {{r0-r7, lr}}

    ldr r3, =SIO_GPIO_25_MASK
    ldr r1, =GPIO_OUT_ADR
    str r3, [r1]

    pop {{r0-r7, pc}}

.global xled_off
.thumb_func
xled_off:
    // *****************************************************
    // Turn the LED off
    // *****************************************************
    push {{r0-r7, lr}}

    ldr r3, =0x00
    ldr r1, =GPIO_OUT_ADR
    str r3, [r1]

    pop {{r0-r7, pc}}


