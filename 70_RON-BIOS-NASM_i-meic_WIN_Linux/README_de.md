# 70_RON-BIOS-NASM_i-meic_WIN_Linux — RON-BIOS (8086-BIOS)

*(English version: [README.md](README.md))*


Das **RON-BIOS** ist das BIOS des i-meic, geschrieben in **8086-Assembler
für NASM**. Es wird zu einem Binär-BIOS übersetzt und anschließend in die
Pico-Firmware eingebettet, die es beim Start in den SRAM lädt.

- Zielprozessor: **8086** (`BITS 16`, `CPU 8086`)
- BIOS-Segment: **`F800:0000`**, Stack bei `FF00`
- Build unter **Windows und Linux** (NASM-Binaries liegen bei)

## Aufbau

Das BIOS ist modular aus mehreren Assembler-Dateien aufgebaut, die in
`BIOS.ASM` zusammengeführt werden:

| Datei | Inhalt |
|-------|--------|
| `BIOS.ASM` | Haupt-/Einstiegsdatei, bindet die Module ein. |
| `BDA.ASM` | BIOS Data Area. |
| `EQUDISK.ASM` | Konstanten/Definitionen für Laufwerke. |
| `INT08.ASM` | Timer-Interrupt (System-Tick). |
| `INT10.ASM` | Video-Dienste (Bildschirmausgabe). |
| `INT13.ASM` | Disketten-/Festplatten-Dienste. |
| `INT16.ASM` | Tastatur-Dienste. |
| `INT1A.ASM` | Uhrzeit/Datum (RTC). |
| `INT02.ASM`, `INT18.ASM`, `INT1D.txt`, `INT33.ASM` | Weitere Interrupts (u. a. Maus, INT 33h). |
| `VGABIOS.ASM` | Video-BIOS-Anteil. |
| `DEBUG.ASM` | Debug-Hilfen. |
| `BIOS.INC` | Erzeugtes Include (Zwischenstand, wird per COM2INC gebaut). |
| `BIOS.BIN` | **Fertiges Binär-BIOS** (Ergebnis von NASM). |

## Mitgelieferte Werkzeuge

| Datei | Zweck |
|-------|-------|
| `nasm.exe` / `nasm` | NASM-Assembler für Windows bzw. Linux. |
| `COM2INC.exe` / `COM2INC` | Wandelt `BIOS.BIN` in `BIOS.INC` (Byte-Array). |
| `run_win.bat` | Build-Skript für Windows. |
| `run_linux.sh` | Build-Skript für Linux. |
| `LICENSE_NASM.TXT` | Lizenz von NASM. |

## BIOS bauen

**Windows:** `run_win.bat` ausführen.
**Linux:** `run_linux.sh` ausführen.

Beide führen im Kern dieselben Schritte aus:

```
nasm -f bin BIOS.ASM -o BIOS.BIN          # 8086-BIOS assemblieren
COM2INC BIOS.BIN BIOS.INC Laenge_BIOS_Array BIOS_ARR   # in Byte-Array wandeln
```

Anschließend wird `BIOS.INC` in die Pico-Firmware unter
`10_i-meic-pico_V6/20_Lazarus_PICO_i-meic-pico_V6_DOS/20_i-meic-pico_V6_DOS/`
kopiert (das Windows-Skript erledigt das automatisch). Danach die Firmware
neu übersetzen, damit das aktualisierte BIOS wirksam wird.

> **Verbindung zur Hardware:** Die im BIOS definierten I/O-Befehlscodes
> (z. B. `IORQ_CONIN`, `IORQ_READ`, `IORQ_VIDEO_SEND`) entsprechen den
> Funktionen, die die Pico-Firmware bedient. BIOS und Firmware müssen daher
> zueinander passen.
