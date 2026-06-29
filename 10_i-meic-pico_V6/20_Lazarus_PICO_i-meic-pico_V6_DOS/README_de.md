# 20_Lazarus_PICO_i-meic-pico_V6_DOS — Pico-Firmware (I/O-Schnittstelle für DOS)

*(English version: [README.md](README.md))*


Quelltext der **Firmware für den Raspberry Pi Pico (RP2040)** auf dem
i-meic-Board. Die Firmware macht aus dem 8086-Kern einen lauffähigen
Rechner, indem sie dessen gesamte Ein-/Ausgabe übernimmt.

## Zur Bedeutung des Ordnernamens

Der Name setzt sich aus zwei Teilen zusammen:

- **`Lazarus_PICO`** — Der RP2040 des Raspberry Pi Pico ist ein
  **ARM-Mikrocontroller** (Cortex-M0+). In diesem Ordner liegt daher der
  Quelltext für den **Lazarus/Free-Pascal-Cross-Compiler für ARM**, also
  „bare-metal"-Pascal, das direkt auf dem Pico läuft (kein klassisches
  Desktop-Lazarus).
- **`i-meic-pico_V6_DOS`** — bezieht sich auf die **Funktionalität der
  I/O-Schnittstelle** für den SBC. Diese Ausführung ist für das
  Betriebssystem **DOS** erstellt.

> **Schwester-Variante:** Für **dasselbe Board** gibt es eine Version mit
> einer I/O-Schnittstelle für **CP/M-86**:
> `Lazarus_PICO_i-meic-pico_V6_CPM86`. Hardware und Cross-Compiler sind
> identisch, nur die I/O-Funktionalität ist auf das jeweilige Betriebssystem
> abgestimmt.

## Aufgaben der Firmware

- **Hardware-Initialisierung** des Pico (GPIO, UART, SPI, Timer)
- **Laden des BIOS** (`BIOS.INC` → Array `BIOS_ARR`) in den SRAM des 8088
  (Segment `F800:0000`)
- **Takten der 8088-CPU** und Steuern von RESET, RAM-Enable usw.
- **Bedienen aller I/O-Anforderungen (IORQ)** der CPU: Konsole, Laufwerke,
  Uhr, Sound, Maus … — hier ausgelegt für **DOS**
- **Serielle Kommunikation** mit dem Host (Standard: **921600 Baud**)
- **ITP3-Erweiterungsbus** (Device-Select DS0–DS3)

## Projektstruktur

| Datei / Ordner | Bedeutung |
|----------------|-----------|
| `20_i-meic-pico_V6_DOS/imeic_dos.lpi` | **Lazarus-Projektdatei** – hiermit das Projekt öffnen. |
| `20_i-meic-pico_V6_DOS/imeic_dos.lpr` | Hauptprogramm (Startablauf der Firmware). |
| `20_i-meic-pico_V6_DOS/GlobalHW_U.PAS` | Hardware-Schicht: GPIO, UART, SPI, Daten-/Adressbus des 8088. |
| `20_i-meic-pico_V6_DOS/GlobalDEF_U.PAS` | Globale Definitionen, Gerätekonstanten, Datenstrukturen. |
| `20_i-meic-pico_V6_DOS/BIOSAdmin_U.PAS` | Verwaltung/Einbinden des BIOS und des BIOS-Flash. |
| `20_i-meic-pico_V6_DOS/DeviceManager_U.PAS` | Geräteverwaltung; bedient die I/O-Funktionen für die 8088-CPU. |
| `20_i-meic-pico_V6_DOS/DeviceManager_DOS_IO.INC` | I/O-Routinen speziell für **DOS**. |
| `20_i-meic-pico_V6_DOS/DeviceManager_CPU8088.INC` | CPU-spezifische Routinen (8088-Bustakt). |
| `20_i-meic-pico_V6_DOS/ITP3_SRV_U.PAS` | Server für den ITP3-Erweiterungsbus. |
| `20_i-meic-pico_V6_DOS/UART_U.PAS` | Serielle Schnittstelle. |
| `20_i-meic-pico_V6_DOS/SysTick_U.PAS`, `SysUtils_U.PAS` | Zeit-/Hilfsfunktionen. |
| `20_i-meic-pico_V6_DOS/BIOS.INC` | **Eingebettetes 8088-BIOS** als Byte-Array (aus `70_RON-BIOS-NASM…` erzeugt). |
| `20_i-meic-pico_V6_DOS/bin/imeic_dos.uf2` | **Fertige Firmware** zum Flashen des Pico. Außerdem `.elf`, `.hex`, `.bin`. |
| `units/` | **Bibliotheken für den ARM-Cross-Compiler** – siehe nächster Abschnitt. |

## Der Ordner `units/` (angepasste Bibliotheken von Michael Ring)

Der Unterordner `units/` enthält die **Free-Pascal-Bibliotheken für den
RP2040 von Michael Ring**. Sie waren eine **wichtige Grundlage** für die
Entwicklung dieser Cross-Quelltexte – ohne sie hätte es diese Variante mit
dem Pico/RP2040 nicht gegeben. Sie stellen den Hardware-Zugriff (GPIO, UART,
SPI, I²C, Timer, Multicore …) sowie diverse Treiber (Displays wie SSD1306 /
ST7735 / ST7789, Fonts, GPS, RTC u. a.) für den ARM-Cross-Compiler bereit.

Original-Projekt von Michael Ring:
**https://github.com/michael-ring/pico-fpcexamples**

> ⚠️ **Wichtig:** Die hier mitgelieferten Units wurden für dieses Projekt
> **verändert und angepasst** (z. B. wurden einige Pointer-Nutzungen
> entfernt). Der Ordner `units/` darf **auf keinen Fall** durch die aktuelle
> Version aus dem Original-Repository ersetzt werden – andernfalls kommt es
> beim Übersetzen zu zahlreichen Fehlermeldungen. Es ist **immer der
> mitgelieferte `units/`-Ordner** zu verwenden.

## Bauen und Flashen

1. `20_i-meic-pico_V6_DOS/imeic_dos.lpi` in **Lazarus** öffnen
   (Free-Pascal-**ARM-Cross-Toolchain** für den RP2040 muss eingerichtet
   sein; die **mitgelieferten** Units aus `units/` werden benötigt – nicht
   die Upstream-Version).
2. Projekt übersetzen → es entsteht `bin/imeic_dos.uf2`.
3. Pico im **BOOTSEL-Modus** anschließen (BOOTSEL-Taste beim Einstecken
   halten) und die `imeic_dos.uf2` auf das erscheinende Laufwerk kopieren.

## BIOS aktualisieren

Bei Änderungen am BIOS zuerst im Ordner
`70_RON-BIOS-NASM_i-meic_WIN_Linux/` neu bauen (erzeugt `BIOS.INC`), die
`BIOS.INC` hierher kopieren und die Firmware neu übersetzen.

> **Hinweis:** Die Baudrate lässt sich in `GlobalHW_U.PAS` umstellen; sie
> muss mit der Einstellung in CONSOLE64 übereinstimmen.
