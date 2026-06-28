# 25_LAZ_CLI64_COM2INC — COM2INC

**COM2INC** is a small command-line tool (Free Pascal / Lazarus) that converts
a **binary file into an include file containing a byte array**. This makes it
possible, for example, to embed the finished BIOS binary (`BIOS.BIN`) as a
Pascal array into the Pico firmware.

Runs on **Windows 64-bit and Linux**.

*(Deutsche Version: [README_de.md](README_de.md))*

## Function

```
COM2INC  <input.BIN>  <output.INC>  <length-constant>  <array-name>  [CLEAR]
```

| Parameter | Meaning |
|-----------|---------|
| `input.BIN` | any binary file (e.g. `BIOS.BIN`, `CPD5.COM`). |
| `output.INC` | generated include containing the byte array. |
| `length-constant` | name of the generated length constant (e.g. `Laenge_BIOS_Array`). |
| `array-name` | name of the generated array (e.g. `BIOS_ARR`). |
| `CLEAR` | optional; cleans/initialises the output. |

**Example** (see `run_win.bat`):

```
COM2INC.exe CPD5.COM CPD5.INC Laenge_BIOS_Array BIOS_ARR CLEAR
```

The result is an `.INC` file of the form
`BIOS_ARR : array[0..Laenge_BIOS_Array] of Byte = ( … );` that can be included
into the Pascal source via `{$I …}`.

## Folder contents

| File | Meaning |
|------|---------|
| `COM2INC.lpi` / `.lpr` | Lazarus project and source. |
| `COM2INC.exe` | Executable (Windows). |
| `COM2INC` | Executable (Linux). |
| `CPD5.COM` / `CPD5.INC` | Example: input binary and generated include. |
| `run_win.bat` / `run_linux.sh` | Invocation examples for Windows and Linux. |
| `LICENSE_NASM.TXT` | License of the bundled NASM components. |

## Relation to the BIOS

The same tool is used in the folder `70_RON-BIOS-NASM_i-meic_WIN_Linux/` to
generate the `BIOS.INC` for the firmware from `BIOS.BIN`.
