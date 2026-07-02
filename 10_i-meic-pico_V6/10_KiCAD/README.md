# 10_KiCAD — Hardware design of the i-meic board (KiCAD)

This folder contains everything needed to **have the i-meic PCB
manufactured** and to **develop the hardware further**.

*(Deutsche Version: [README_de.md](README_de.md))*

## Most important files

| File / folder | Purpose |
|---------------|---------|
| `gerber_i-meic-pico_V6.zip` | **Fabrication data (Gerber + drill).** Can be uploaded directly to a PCB manufacturer. |
| `i-meic-pico_V6.pdf` | Schematic / layout as PDF for viewing and printing. |
| `i-meic-pico_V6.svg` | Vector view of the board. |
| `i-meic-pico_V6.jpg` | Image of the board for a quick overview. |
| `i-meic-pico_V6/` | The actual **KiCAD project** (see below). |

## KiCAD project folder `i-meic-pico_V6/`

| File | Meaning |
|------|---------|
| `i-meic-pico_V6.kicad_pro` | KiCAD project file (open the project with this). |
| `i-meic-pico_V6.kicad_sch` | Schematic. |
| `i-meic-pico_V6.kicad_pcb` | PCB layout. |
| `i-meic-pico_V6.kicad_prl` | Local project settings. |
| `board-library/` | **Project-specific component library** with symbols (`.kicad_sym`) and footprints (`.pretty/*.kicad_mod`) – for RP2040 modules, SRAM, LCDs, ITP3 connectors, switches and more. |

## Having the PCB manufactured

1. Upload `gerber_i-meic-pico_V6.zip` unchanged to a PCB manufacturer.
2. Choose the usual parameters (e.g. 2 layers, 1.6 mm, HASL/ENIG).
3. After receiving the board, populate it according to the schematic.

## Developing further

Open the project with **KiCAD** via `i-meic-pico_V6.kicad_pro`. For the
project-specific parts to load correctly, keep the `board-library/` folder as
a library path relative to the project.


