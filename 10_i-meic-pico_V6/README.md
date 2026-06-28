# 10_i-meic-pico_V6 — The i-meic board (hardware & firmware)

This folder contains **one complete i-meic variant**: the hardware (KiCAD)
and the matching Pico firmware for DOS operation.

The suffix **`pico_V6`** denotes hardware revision 6 of the board, in which
all I/O is handled by a **Raspberry Pi Pico (RP2040)**.

*(Deutsche Version: [README_de.md](README_de.md))*

## Contents

| Subfolder | Description |
|-----------|-------------|
| [`10_KiCAD/`](10_KiCAD/) | KiCAD project: schematic, PCB layout, Gerber data and component library. The PCB can be ordered **and** developed further here. |
| [`20_Lazarus_PICO_i-meic-pico_V6_DOS/`](20_Lazarus_PICO_i-meic-pico_V6_DOS/) | Source of the **Pico firmware** for the **ARM cross-compiler** (Free Pascal / Lazarus, "bare-metal" on the RP2040). The I/O interface here is built for **DOS**. Produces the `imeic_dos.uf2` for flashing the Pico. |

> **About the firmware folder name:** `Lazarus_PICO` refers to the Free
> Pascal / Lazarus **cross-compiler for the ARM core** of the RP2040 (the
> Pico is an ARM microcontroller, not x86). The suffix `…_DOS` refers to the
> **functionality of the I/O interface** for the SBC, which is built for DOS.
>
> **Further operating-system variant (same board):** For the same board there
> is a version with an I/O interface for **CP/M-86**
> (`Lazarus_PICO_i-meic-pico_V6_CPM86`). The hardware and the ARM
> cross-compiler stay the same; only the I/O functionality is tailored to the
> respective operating system.

## How it fits together

The hardware from `10_KiCAD` and the firmware from
`20_Lazarus_PICO_i-meic-pico_V6_DOS` belong directly together:

1. The PCB is manufactured according to the KiCAD/Gerber data and populated.
2. The firmware is compiled and flashed onto the Raspberry Pi Pico.
3. At startup the Pico loads the BIOS into the SRAM, clocks the 8086 CPU and
   services all of its I/O.

Screen, keyboard and drives are provided over the serial interface by the
host program **CONSOLE64**
(`60_FPC_Lazarus/20_LAZ_Console64_GUI64_Win64_Linux/`).

> The BIOS used here is built from the folder
> `70_RON-BIOS-NASM_i-meic_WIN_Linux/` and embedded into the firmware as
> `BIOS.INC`.
