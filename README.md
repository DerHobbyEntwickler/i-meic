# i-meic

*(German version: [README_de.md](README_de.md))*


**The i-meic is a modular, expandable single-board computer based on the Intel 8088 CPU.**

> The hardware aims to recreate an IBM PC using the simplest possible means.
> The PC compute core consists of the 8088 CPU and 1 MB of main memory.
> All input/output is handled by a Raspberry Pi RP2040 Pro Micro.
> That is faster, simpler and cheaper than classic peripheral chips.

---

## What does "i-meic" mean?

The name is derived from the German description of the project:

| Letter | Meaning  |
|--------|-----------|
| **i** | (**i**)ntel 8088 |
| **m** | (**m**)odular|
| **e** | (**e**)xpandable |
| **i** | s(**i**)ngle-board |
| **c** | (**c**)omputer |

---

## Concept in brief

Classic 8088 systems require a large number of peripheral chips
(clock generator, bus drivers, interrupt controller, DMA, floppy/HDD
controller, video, keyboard, etc.). The i-meic replaces this entire set of
peripherals with **a single microcontroller**: the Raspberry Pi Pico.

**The PC compute core consists of:**

- **1× Intel 8088 CPU** (16-bit, 20 address lines)
- **2× SRAM of 512 KByte each** → together **1 MByte** (the maximum of the
  8088 address space)

**The Raspberry Pi RP2040 Pro Micro (ARM Cortex-M0+) takes care of:**

- **clock generation** for the 8088 CPU (single-step / clocked operation)
- **loading the BIOS** into SRAM at startup
- the **complete I/O processing** (every read/write access to an I/O port
  is intercepted and serviced by the Pico)
- the **serial connection** to a host PC (screen, keyboard and drives are
  virtualized over the console)
- the **ITP3 interface** for modular expansion


This architecture is unusually powerful because the Pico runs at a
significantly higher clock frequency than the historic 8088 peripherals and
can therefore handle I/O operations very quickly.

---

## System and data flow

This is how a runnable DOS computer is created from source code:

```
   ┌────────────────────────────────────────────────────────────────┐
   │  70_RON-BIOS-NASM …  BIOS.ASM  (8088 assembler, NASM)          │
   │        │  nasm -f bin                                          │
   │        ▼                                                       │
   │     BIOS.BIN  (pure 8088 binary BIOS, segment F800:0000)       │
   │        │  COM2INC  (see 60_FPC_Lazarus/25_LAZ_CLI64_COM2INC)   │
   │        ▼                                                       │
   │     BIOS.INC  (Pascal byte array  BIOS_ARR[…])                 │
   └────────┬───────────────────────────────────────────────────────┘
            │  gets embedded into the Pico firmware
            ▼
   ┌────────────────────────────────────────────────────────────────┐
   │  10_…/20_Lazarus_PICO…  Firmware (Free Pascal / RP2040)        │
   │        │  Lazarus / FPC                                        │
   │        ▼                                                       │
   │     imeic_dos.uf2   →   flash onto the Raspberry Pi Pico       │
   └────────┬───────────────────────────────────────────────────────┘
            │  Pico boots:
            │  1. loads BIOS_ARR into SRAM (F800:0000)
            │  2. clocks the 8088 CPU
            │  3. services all I/O requests (IORQ)
            ▼
   ┌────────────────────────────────────────────────────────────────┐
   │  i-meic board  (8088 + 2×512 KB SRAM)  ←── serial ───┐         │
   └──────────────────────────────────────────────────────┼─────────┘
                                                           │ UART 921600 Bd
   ┌───────────────────────────────────────────────────────▼────────┐
   │  60_…/20_LAZ_Console64 …  CONSOLE64  (host PC, Win64/Linux)    │
   │  provides screen, keyboard and drive images:                  │
   │    BOOTA.IMG  (1.44 MB floppy)     BOOTC.IMG  (8 MB hard disk) │
   └────────────────────────────────────────────────────────────────┘
```

---

## Repository structure

| Folder | Contents |
|--------|--------|
| [`10_i-meic-pico_V6/`](10_i-meic-pico_V6/) | The actual i-meic board: KiCAD hardware **and** Pico firmware (ARM cross-compiler, I/O interface for DOS) |
| [`10_i-meic-pico_V6/10_KiCAD/`](10_i-meic-pico_V6/10_KiCAD/) | KiCAD project, schematic, layout, Gerber data for PCB manufacturing |
| [`10_i-meic-pico_V6/20_Lazarus_PICO_i-meic-pico_V6_DOS/`](10_i-meic-pico_V6/20_Lazarus_PICO_i-meic-pico_V6_DOS/) | Source code of the Pico firmware for the **ARM cross-compiler** (Free Pascal / Lazarus). The I/O interface here is designed for **DOS**. |
| [`60_FPC_Lazarus/`](60_FPC_Lazarus/) | Host PC tools (Free Pascal / Lazarus) for Windows & Linux |
| [`60_FPC_Lazarus/20_LAZ_Console64_GUI64_Win64_Linux/`](60_FPC_Lazarus/20_LAZ_Console64_GUI64_Win64_Linux/) | **CONSOLE64** – terminal/console program for all i-meic (central tool) |
| [`60_FPC_Lazarus/25_LAZ_CLI64_COM2INC/`](60_FPC_Lazarus/25_LAZ_CLI64_COM2INC/) | **COM2INC** – command-line tool that converts a binary file into a Pascal/NASM include (byte array) |
| [`70_RON-BIOS-NASM_i-meic_WIN_Linux/`](70_RON-BIOS-NASM_i-meic_WIN_Linux/) | **RON-BIOS** – the 8088 BIOS in NASM assembler including build scripts |

>
> **Operating-system variants of the firmware:** For the **i-meic board**
> there are several firmware variants that differ only in the I/O interface –
> currently **DOS** (`…_DOS`) and **CP/M-86** (`…_CPM86`). The hardware and the
> ARM cross-compiler are identical in each case.

---

## Quick start

### 1. Have the PCB manufactured
The ready-to-use Gerber data is located at
`10_i-meic-pico_V6/10_KiCAD/gerber_i-meic-pico_V6.zip` and can be uploaded
directly to a PCB manufacturer. The schematic and layout for further
development are in the same folder as a KiCAD project.

### 2. Flash the Pico firmware
Copy `imeic_dos.uf2` onto the Raspberry Pi Pico (BOOTSEL mode).

### 3. Start the console and connect
Start `CONSOLE64` (in the folder
`60_FPC_Lazarus/20_LAZ_Console64_GUI64_Win64_Linux/bin/`), set the correct
COM port and 921600 baud, then power up the i-meic.

---

## Requirements

- **Hardware:** Intel 8088, 2× SRAM (512 KByte), Raspberry Pi Pico or a
  compatible RP2040 module (footprints for several variants are provided),
  serial connection to the host
- **Software (development):**
  - [KiCAD](https://www.kicad.org/) for the hardware
  - [Lazarus / Free Pascal](https://www.lazarus-ide.org/) including the
    **ARM cross-toolchain** for the RP2040 (the Pico is an ARM
    microcontroller); the firmware runs "bare-metal" on the Pico
  - RP2040 libraries by **Michael Ring** as a basis (included in the `units/`
    folder, **adapted for this project** – see the warning below), original:
    <https://github.com/michael-ring/pico-fpcexamples>
  - [NASM](https://www.nasm.us/) for the BIOS (binaries are included)

---

## Acknowledgements / third parties

- The Free Pascal libraries for the RP2040 come from **Michael Ring**:
  <https://github.com/michael-ring/pico-fpcexamples>. They were an
  **important basis** for this Pico/RP2040 variant.
  ⚠️ The libraries shipped in the `units/` folder have been **modified and
  adapted** for this project and **must not** be replaced by the current
  upstream version (otherwise compilation errors will occur).
- **NASM** is used to assemble the 8088 BIOS (see `LICENSE_NASM.TXT`).

---

## License

This project is licensed under the **GNU General Public License v3.0** – see
[`LICENSE`](LICENSE). The BIOS and COM2INC additionally include the NASM
license (`LICENSE_NASM.TXT`) for the bundled NASM binaries.
