# 70_RON-BIOS-NASM_i-meic_WIN_Linux — RON-BIOS (8086 BIOS)

The **RON-BIOS** is the BIOS of the i-meic, written in **8086 assembly for
NASM**. It is assembled into a binary BIOS and then embedded into the Pico
firmware, which loads it into the SRAM at startup.

- Target processor: **8086** (`BITS 16`, `CPU 8086`)
- BIOS segment: **`F800:0000`**, stack at `FF00`
- Builds on **Windows and Linux** (NASM binaries are included)

*(Deutsche Version: [README_de.md](README_de.md))*

## Structure

The BIOS is built modularly from several assembly files that are combined in
`BIOS.ASM`:

| File | Contents |
|------|----------|
| `BIOS.ASM` | Main/entry file, includes the modules. |
| `BDA.ASM` | BIOS Data Area. |
| `EQUDISK.ASM` | Constants/definitions for drives. |
| `INT08.ASM` | Timer interrupt (system tick). |
| `INT10.ASM` | Video services (screen output). |
| `INT13.ASM` | Floppy/hard-disk services. |
| `INT16.ASM` | Keyboard services. |
| `INT1A.ASM` | Time/date (RTC). |
| `INT02.ASM`, `INT18.ASM`, `INT1D.txt`, `INT33.ASM` | Further interrupts (incl. mouse, INT 33h). |
| `VGABIOS.ASM` | Video-BIOS part. |
| `DEBUG.ASM` | Debugging helpers. |
| `BIOS.INC` | Generated include (intermediate state, built via COM2INC). |
| `BIOS.BIN` | **Finished binary BIOS** (result of NASM). |

## Bundled tools

| File | Purpose |
|------|---------|
| `nasm.exe` / `nasm` | NASM assembler for Windows and Linux. |
| `COM2INC.exe` / `COM2INC` | Converts `BIOS.BIN` into `BIOS.INC` (byte array). |
| `run_win.bat` | Build script for Windows. |
| `run_linux.sh` | Build script for Linux. |
| `LICENSE_NASM.TXT` | License of NASM. |

## Building the BIOS

**Windows:** run `run_win.bat`.
**Linux:** run `run_linux.sh`.

In essence both perform the same steps:

```
nasm -f bin BIOS.ASM -o BIOS.BIN          # assemble the 8086 BIOS
COM2INC BIOS.BIN BIOS.INC Laenge_BIOS_Array BIOS_ARR   # convert to byte array
```

Afterwards `BIOS.INC` is copied into the Pico firmware under
`10_i-meic-pico_V6/20_Lazarus_PICO_i-meic-pico_V6_DOS/20_i-meic-pico_V6_DOS/`
(the Windows script does this automatically). Then recompile the firmware so
that the updated BIOS takes effect.

> **Connection to the hardware:** The I/O command codes defined in the BIOS
> (e.g. `IORQ_CONIN`, `IORQ_READ`, `IORQ_VIDEO_SEND`) correspond to the
> functions serviced by the Pico firmware. The BIOS and firmware must
> therefore match each other.
