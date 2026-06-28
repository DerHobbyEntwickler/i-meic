# 60_FPC_Lazarus — Host-PC tools (Free Pascal / Lazarus)

This folder bundles the **PC programs** around the i-meic, written in **Free
Pascal / Lazarus** and running on **Windows 64-bit and Linux**. They run on
the host computer, not on the i-meic itself.

*(Deutsche Version: [README_de.md](README_de.md))*

## Contents

| Subfolder | Program | Purpose |
|-----------|---------|---------|
| [`20_LAZ_Console64_GUI64_Win64_Linux/`](20_LAZ_Console64_GUI64_Win64_Linux/) | **CONSOLE64** | Central terminal/console program. Provides the i-meic with screen, keyboard and drive images over the serial interface. **Required for all i-meic.** |
| [`25_LAZ_CLI64_COM2INC/`](25_LAZ_CLI64_COM2INC/) | **COM2INC** | Command-line tool that converts a binary file (e.g. the BIOS) into a Pascal/NASM include containing a byte array. |

## A note on the consoles

CONSOLE64 is the console stored here – there are **several consoles** for
different i-meic variants, which will be added over time. The numbering
(`20_`, `25_`, …) deliberately leaves room for this.

## Building

All programs can be opened and compiled with **Lazarus** via their respective
`*.lpi` file. Precompiled binaries (`.exe` for Windows, the executable
without an extension for Linux) are included for direct use.
