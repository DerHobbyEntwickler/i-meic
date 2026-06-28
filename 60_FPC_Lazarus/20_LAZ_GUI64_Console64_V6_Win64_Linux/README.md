# 20_LAZ_Console64_GUI64_Win64_Linux — CONSOLE64

**CONSOLE64** is the central host program for the i-meic. It connects to the
board over the serial interface and provides it with all the "visible"
peripherals:

- **Screen / video terminal** (with Codepage 437 character set)
- **Keyboard**
- **Drives** as disk images (floppy and hard disk)

Without this console the i-meic has neither display nor input – it is
therefore **required for all i-meic**. It runs on **Windows 64-bit and Linux**
(GUI application based on the LCL).

*(Deutsche Version: [README_de.md](README_de.md))*

## Folder structure

| Folder / file | Meaning |
|---------------|---------|
| `bin/CONSOLE64.exe` | Executable (Windows). |
| `bin/CONSOLE64` | Executable (Linux). |
| `bin/CONSOLE64.ini` | Configuration: COM port, baud rate, font, language, logging. |
| `bin/IMAGE_FDD/BOOTA.IMG` | Floppy image (1.44 MB) – drive A:. |
| `bin/IMAGE_HDD/BOOTC.IMG` | Hard disk image (8 MB) – drive C:. |
| `src/` | Lazarus source code. |

### Important source files (`src/`)

| File | Contents |
|------|----------|
| `CONSOLE64.lpi` / `.lpr` | Lazarus project and main program. |
| `MainUnit.pas` / `.lfm` | Main window and program logic. |
| `Unit_CONS.pas` / `.lfm` | Console/terminal window. |
| `Video_Send.INC` | Preparation of the video output to/from the i-meic. |
| `Codepage437.INC` | DOS character set (Codepage 437). |
| `Keyboard.INC` | Keyboard handling. |
| `language_u.pas`, `language_de.INC`, `language_en.INC` | Multilingual support (German/English). |
| `synaser/` | Serial library (Synaser) for the COM-port communication. |
| `windos.pas` | Helper routines. |

## Operation

1. Start the program (`CONSOLE64.exe` or `./CONSOLE64`).
2. In the settings, select the correct **COM port** and the **baud rate**. The
   baud rate must match the firmware (firmware default: **921600 baud**).
3. If needed, assign the disk images in `IMAGE_FDD/` and `IMAGE_HDD/`.
4. Power up the i-meic – the console shows the output and forwards keyboard
   input.

The settings are stored in `CONSOLE64.ini`.

> **Tip:** Your own DOS floppies/hard disks can be used by replacing
> `BOOTA.IMG` / `BOOTC.IMG` (keep the same image size).
