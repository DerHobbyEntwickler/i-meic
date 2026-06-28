# 20_Lazarus_PICO_i-meic-pico_V6_DOS — Pico firmware (I/O interface for DOS)

Source of the **firmware for the Raspberry Pi Pico (RP2040)** on the i-meic
board. The firmware turns the 8086 core into a working computer by taking
over all of its input/output.

*(Deutsche Version: [README_de.md](README_de.md))*

## About the folder name

The name consists of two parts:

- **`Lazarus_PICO`** — The RP2040 of the Raspberry Pi Pico is an **ARM
  microcontroller** (Cortex-M0+). This folder therefore contains the source
  for the **Lazarus / Free Pascal cross-compiler for ARM**, i.e.
  "bare-metal" Pascal that runs directly on the Pico (not classic desktop
  Lazarus).
- **`i-meic-pico_V6_DOS`** — refers to the **functionality of the I/O
  interface** for the SBC. This build is made for the **DOS** operating
  system.

> **Sister variant:** For **the same board** there is a version with an I/O
> interface for **CP/M-86**: `Lazarus_PICO_i-meic-pico_V6_CPM86`. The hardware
> and cross-compiler are identical; only the I/O functionality is tailored to
> the respective operating system.

## Tasks of the firmware

- **Hardware initialisation** of the Pico (GPIO, UART, SPI, timer)
- **Loading the BIOS** (`BIOS.INC` → array `BIOS_ARR`) into the SRAM of the
  8086 (segment `F800:0000`)
- **Clocking the 8086 CPU** and controlling RESET, RAM enable, etc.
- **Servicing all I/O requests (IORQ)** of the CPU: console, drives, clock,
  sound, mouse … — here built for **DOS**
- **Serial communication** with the host (default: **921600 baud**)
- **ITP3 expansion bus** (device select DS0–DS3)

## Project structure

| File / folder | Meaning |
|---------------|---------|
| `20_i-meic-pico_V6_DOS/imeic_dos.lpi` | **Lazarus project file** – open the project with this. |
| `20_i-meic-pico_V6_DOS/imeic_dos.lpr` | Main program (firmware startup sequence). |
| `20_i-meic-pico_V6_DOS/GlobalHW_U.PAS` | Hardware layer: GPIO, UART, SPI, data/address bus of the 8086. |
| `20_i-meic-pico_V6_DOS/GlobalDEF_U.PAS` | Global definitions, device constants, data structures. |
| `20_i-meic-pico_V6_DOS/BIOSAdmin_U.PAS` | Management/embedding of the BIOS and the BIOS flash. |
| `20_i-meic-pico_V6_DOS/DeviceManager_U.PAS` | Device management; services the I/O functions for the 8086 CPU. |
| `20_i-meic-pico_V6_DOS/DeviceManager_DOS_IO.INC` | I/O routines specifically for **DOS**. |
| `20_i-meic-pico_V6_DOS/DeviceManager_CPU8088.INC` | CPU-specific routines (8086/8088 bus timing). |
| `20_i-meic-pico_V6_DOS/ITP3_SRV_U.PAS` | Server for the ITP3 expansion bus. |
| `20_i-meic-pico_V6_DOS/UART_U.PAS` | Serial interface. |
| `20_i-meic-pico_V6_DOS/SysTick_U.PAS`, `SysUtils_U.PAS` | Time/utility functions. |
| `20_i-meic-pico_V6_DOS/BIOS.INC` | **Embedded 8086 BIOS** as a byte array (generated from `70_RON-BIOS-NASM…`). |
| `20_i-meic-pico_V6_DOS/bin/imeic_dos.uf2` | **Finished firmware** for flashing the Pico. Also `.elf`, `.hex`, `.bin`. |
| `units/` | **Libraries for the ARM cross-compiler** – see the next section. |

## The `units/` folder (adapted libraries by Michael Ring)

The `units/` subfolder contains the **Free Pascal libraries for the RP2040 by
Michael Ring**. They were an **important foundation** for developing these
cross-compiled sources – without them this Pico/RP2040 variant would not
exist. They provide hardware access (GPIO, UART, SPI, I²C, timer, multicore …)
as well as various drivers (displays such as SSD1306 / ST7735 / ST7789, fonts,
GPS, RTC, etc.) for the ARM cross-compiler.

Original project by Michael Ring:
**https://github.com/michael-ring/pico-fpcexamples**

> ⚠️ **Important:** The units shipped here have been **modified and adapted**
> for this project (for example, some pointer usages were removed). The
> `units/` folder must **not** be replaced with the current version from the
> original repository – otherwise compilation will produce numerous errors.
> **Always use the bundled `units/` folder.**

## Build and flash

1. Open `20_i-meic-pico_V6_DOS/imeic_dos.lpi` in **Lazarus** (the Free Pascal
   **ARM cross-toolchain** for the RP2040 must be set up; the **bundled**
   units from `units/` are required – not the upstream version).
2. Compile the project → this produces `bin/imeic_dos.uf2`.
3. Connect the Pico in **BOOTSEL mode** (hold the BOOTSEL button while
   plugging it in) and copy `imeic_dos.uf2` onto the drive that appears.

## Updating the BIOS

When changing the BIOS, first rebuild it in the folder
`70_RON-BIOS-NASM_i-meic_WIN_Linux/` (produces `BIOS.INC`), copy the
`BIOS.INC` here and recompile the firmware.

> **Note:** The baud rate can be changed in `GlobalHW_U.PAS`; it must match the
> setting in CONSOLE64.
