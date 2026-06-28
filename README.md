# i-meic

**The i-meic is a modularly expandable single-board computer based on the
Intel 8086 CPU.**

> The entire processing core consists of nothing more than the CPU and the
> main memory. All input/output is handled by a Raspberry Pi Pico (RP2040) –
> fast, flexible and without any classic peripheral chips.

*(Deutsche Version: [README_de.md](README_de.md))*

---

## What does "i-meic" mean?

The name is derived from the German description of the project:

| Letter | Meaning (German) | English |
|--------|------------------|---------|
| **i** | **i**ntel 8086 | Intel 8086 |
| **m** | **m**odularer | modular |
| **e** | **e**rweiterbarer | expandable |
| **i** | e**i**nplatinen | single-board |
| **c** | **c**omputer | computer |

---

## Concept in brief

Classic 8086 systems require a large number of peripheral chips (clock
generator, bus drivers, interrupt controller, DMA, floppy/HDD controller,
video, keyboard, etc.). The i-meic replaces this entire periphery with **a
single microcontroller**: the Raspberry Pi Pico.

**The processing core consists solely of:**

- **1× Intel 8086 CPU** (16-bit, 20 address lines)
- **2× 512 KByte SRAM** → together **1 MByte** (the maximum of the 8086
  address space)

**The Raspberry Pi Pico (RP2040, ARM Cortex-M0+) handles:**

- **clock generation** for the 8086 CPU (single-step / clocked operation)
- **loading the BIOS** into the SRAM at startup
- the **complete I/O processing** (every read/write access to an I/O port is
  intercepted and serviced by the Pico)
- the **serial link** to a host PC (screen, keyboard and drives are
  virtualised over serial)
- the **ITP3 expansion bus** for modular expansion (device select DS0–DS3)

This architecture is unusually capable because the Pico runs at a much higher
clock rate than the historic 8086 periphery and can therefore process I/O
operations very quickly.

---

## System and data flow

This is how source code becomes a working DOS computer:

```
   ┌────────────────────────────────────────────────────────────────┐
   │  70_RON-BIOS-NASM …  BIOS.ASM  (8086 assembly, NASM)            │
   │        │  nasm -f bin                                           │
   │        ▼                                                        │
   │     BIOS.BIN  (pure 8086 binary BIOS, segment F800:0000)        │
   │        │  COM2INC  (see 60_FPC_Lazarus/25_LAZ_CLI64_COM2INC)    │
   │        ▼                                                        │
   │     BIOS.INC  (Pascal byte array  BIOS_ARR[…])                  │
   └────────┬───────────────────────────────────────────────────────┘
            │  embedded into the Pico firmware
            ▼
   ┌────────────────────────────────────────────────────────────────┐
   │  10_…/20_Lazarus_PICO…  Firmware (Free Pascal / ARM RP2040)     │
   │        │  Lazarus / FPC                                         │
   │        ▼                                                        │
   │     imeic_dos.uf2   →   flash onto the Raspberry Pi Pico        │
   └────────┬───────────────────────────────────────────────────────┘
            │  Pico boots:
            │  1. loads BIOS_ARR into the SRAM (F800:0000)
            │  2. clocks the 8086 CPU
            │  3. services all I/O requests (IORQ)
            ▼
   ┌────────────────────────────────────────────────────────────────┐
   │  i-meic board  (8086 + 2×512 KB SRAM)  ←── serial ───┐          │
   └──────────────────────────────────────────────────────┼─────────┘
                                                           │ UART 921600 Bd
   ┌───────────────────────────────────────────────────────▼────────┐
   │  60_…/20_LAZ_Console64 …  CONSOLE64  (host PC, Win64/Linux)     │
   │  provides screen, keyboard and drive images:                   │
   │    BOOTA.IMG  (1.44 MB floppy)     BOOTC.IMG  (8 MB hard disk)  │
   └────────────────────────────────────────────────────────────────┘
```

---

## Repository layout

| Folder | Contents |
|--------|----------|
| [`10_i-meic-pico_V6/`](10_i-meic-pico_V6/) | The actual i-meic board: KiCAD hardware **and** Pico firmware (ARM cross-compiler, I/O interface for DOS) |
| [`10_i-meic-pico_V6/10_KiCAD/`](10_i-meic-pico_V6/10_KiCAD/) | KiCAD project, schematic, layout, Gerber data for PCB fabrication |
| [`10_i-meic-pico_V6/20_Lazarus_PICO_i-meic-pico_V6_DOS/`](10_i-meic-pico_V6/20_Lazarus_PICO_i-meic-pico_V6_DOS/) | Source of the Pico firmware for the **ARM cross-compiler** (Free Pascal / Lazarus). The I/O interface here is built for **DOS**. |
| [`60_FPC_Lazarus/`](60_FPC_Lazarus/) | Host-PC tools (Free Pascal / Lazarus) for Windows & Linux |
| [`60_FPC_Lazarus/20_LAZ_Console64_GUI64_Win64_Linux/`](60_FPC_Lazarus/20_LAZ_Console64_GUI64_Win64_Linux/) | **CONSOLE64** – terminal/console program for all i-meic (central tool) |
| [`60_FPC_Lazarus/25_LAZ_CLI64_COM2INC/`](60_FPC_Lazarus/25_LAZ_CLI64_COM2INC/) | **COM2INC** – command-line tool that converts a binary file into a Pascal/NASM include (byte array) |
| [`70_RON-BIOS-NASM_i-meic_WIN_Linux/`](70_RON-BIOS-NASM_i-meic_WIN_Linux/) | **RON-BIOS** – the 8086 BIOS in NASM assembly incl. build scripts |

> **Note on the numbering:** The prefixes `10_`, `60_`, `70_` deliberately
> leave gaps for further modules and variants (e.g. other consoles, other
> operating-system variants of the firmware) that will be added over time.
>
> **Operating-system variants of the firmware:** For **the same board** there
> are several firmware variants that differ only in their I/O interface –
> currently **DOS** (`…_DOS`) and **CP/M-86** (`…_CPM86`). The hardware and the
> ARM cross-compiler are identical in both cases.

---

## Quick start

### 1. Have the PCB manufactured
The finished Gerber data is located at
`10_i-meic-pico_V6/10_KiCAD/gerber_i-meic-pico_V6.zip` and can be uploaded
directly to a PCB manufacturer. The schematic and layout for further
development are in the same folder as a KiCAD project.

### 2. Build and flash the Pico firmware
Open the project
`imeic_dos.uf2` onto the Raspberry Pi Pico (BOOTSEL mode).

### 3. Start the console and connect
Start `CONSOLE64` (in the folder
`60_FPC_Lazarus/20_LAZ_Console64_GUI64_Win64_Linux/bin/`), set the correct
COM port and 921600 baud, then power up the i-meic.

---

## Requirements

- **Hardware:** Intel 8086, 2× SRAM (512 KByte), Raspberry Pi Pico or
  compatible RP2040 module (footprints for several variants are provided),
  serial connection to the host
- **Software (development):**
  - [KiCAD](https://www.kicad.org/) for the hardware
  - [Lazarus / Free Pascal](https://www.lazarus-ide.org/) incl. the **ARM
    cross-toolchain** for the RP2040 (the Pico is an ARM microcontroller); the
    firmware runs "bare-metal" on the Pico
  - RP2040 libraries by **Michael Ring** as a foundation (included in the
    `units/` folder, **adapted for this project** – see the warning below),
    original: <https://github.com/michael-ring/pico-fpcexamples>
  - [NASM](https://www.nasm.us/) for the BIOS (binaries are included)

---

## Acknowledgements / third parties

- The Free Pascal libraries for the RP2040 are by **Michael Ring**:
  <https://github.com/michael-ring/pico-fpcexamples>. They were an
  **important foundation** for this Pico/RP2040 variant.
  ⚠️ The libraries shipped in the `units/` folder have been **modified and
  adapted** for this project and must **not** be replaced with the current
  upstream version (otherwise compilation errors will occur).
- **NASM** is used to assemble the 8086 BIOS (see `LICENSE_NASM.TXT`).

---

## License

This project is licensed under the **GNU General Public License v3.0** – see
[`LICENSE`](LICENSE). The BIOS and COM2INC additionally include the NASM
license (`LICENSE_NASM.TXT`) for the bundled NASM binaries.

---

## Documentation language

The English `README.md` is the primary documentation. The German version is
available in the same folder as `README_de.md`.

<!--
TODO (to be filled in by the author):
- author / contact / project website
- bill of materials (BOM) for assembly
- photo of the assembled board
- exact pin mapping Pico ↔ 8086 ↔ SRAM
-->
