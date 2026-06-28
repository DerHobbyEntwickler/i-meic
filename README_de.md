# i-meic

*(English version: [README.md](README.md))*


**Der i-meic ist ein modular erweiterbarer Einplatinencomputer auf Basis der Intel-8086-CPU.**

> Der gesamte Rechnerkern besteht nur aus der CPU und dem Arbeitsspeicher.
> Sämtliche Ein-/Ausgabe wird von einem Raspberry Pi Pico (RP2040) übernommen –
> schnell, flexibel und ohne klassische Peripherie-Chips.

---

## Was bedeutet „i-meic"?

Der Name leitet sich aus der deutschen Beschreibung des Projekts ab:

| Buchstabe | Bedeutung |
|-----------|-----------|
| **i** | **i**ntel 8086 |
| **m** | **m**odularer |
| **e** | **e**rweiterbarer |
| **i** | e**i**nplatinen |
| **c** | **c**omputer |

---

## Konzept in Kürze

Klassische 8086-Systeme benötigen eine Vielzahl von Peripheriebausteinen
(Taktgeber, Bustreiber, Interrupt-Controller, DMA, Floppy-/HDD-Controller,
Video, Tastatur usw.). Der i-meic ersetzt diese gesamte Peripherie durch
**einen einzigen Mikrocontroller**: den Raspberry Pi Pico.

**Der Rechnerkern besteht ausschließlich aus:**

- **1× CPU Intel 8086** (16-Bit, 20 Adressleitungen)
- **2× SRAM à 512 KByte** → zusammen **1 MByte** (Maximalausbau des
  8086-Adressraums)

**Der Raspberry Pi Pico (RP2040, ARM Cortex-M0+) übernimmt:**

- die **Takterzeugung** für die 8086-CPU (Single-Step / getakteter Betrieb)
- das **Laden des BIOS** in den SRAM beim Start
- die **komplette I/O-Verarbeitung** (jeder Lese-/Schreibzugriff auf einen
  I/O-Port wird vom Pico abgefangen und bedient)
- die **serielle Anbindung** an einen Host-PC (Bildschirm, Tastatur,
  Laufwerke werden über die Konsole virtualisiert)
- den **ITP3-Erweiterungsbus** zur modularen Erweiterung (Device-Select
  DS0–DS3)

Diese Architektur ist ungewöhnlich leistungsfähig, weil der Pico mit
deutlich höherer Taktfrequenz arbeitet als die historische 8086-Peripherie
und I/O-Operationen damit sehr schnell abwickeln kann.

---

## System- und Datenfluss

So entsteht aus Quelltext ein lauffähiger DOS-Rechner:

```
   ┌────────────────────────────────────────────────────────────────┐
   │  70_RON-BIOS-NASM …  BIOS.ASM  (8086-Assembler, NASM)           │
   │        │  nasm -f bin                                           │
   │        ▼                                                        │
   │     BIOS.BIN  (reines 8086-Binär-BIOS, Segment F800:0000)       │
   │        │  COM2INC  (siehe 60_FPC_Lazarus/25_LAZ_CLI64_COM2INC)  │
   │        ▼                                                        │
   │     BIOS.INC  (Pascal-Byte-Array  BIOS_ARR[…])                  │
   └────────┬───────────────────────────────────────────────────────┘
            │  wird in die Pico-Firmware eingebettet
            ▼
   ┌────────────────────────────────────────────────────────────────┐
   │  10_…/20_Lazarus_PICO…  Firmware (Free Pascal / RP2040)         │
   │        │  Lazarus / FPC                                         │
   │        ▼                                                        │
   │     imeic_dos.uf2   →   auf den Raspberry Pi Pico flashen       │
   └────────┬───────────────────────────────────────────────────────┘
            │  Pico bootet:
            │  1. lädt BIOS_ARR in den SRAM (F800:0000)
            │  2. taktet die 8086-CPU
            │  3. bedient alle I/O-Anforderungen (IORQ)
            ▼
   ┌────────────────────────────────────────────────────────────────┐
   │  i-meic-Board  (8086 + 2×512 KB SRAM)  ←── seriell ──┐          │
   └──────────────────────────────────────────────────────┼─────────┘
                                                           │ UART 921600 Bd
   ┌───────────────────────────────────────────────────────▼────────┐
   │  60_…/20_LAZ_Console64 …  CONSOLE64  (Host-PC, Win64/Linux)     │
   │  liefert Bildschirm, Tastatur und Laufwerks-Images:            │
   │    BOOTA.IMG  (1,44-MB-Diskette)   BOOTC.IMG  (8-MB-Festplatte) │
   └────────────────────────────────────────────────────────────────┘
```

---

## Aufbau des Repositorys

| Ordner | Inhalt |
|--------|--------|
| [`10_i-meic-pico_V6/`](10_i-meic-pico_V6/) | Das eigentliche i-meic-Board: KiCAD-Hardware **und** Pico-Firmware (ARM-Cross-Compiler, I/O-Schnittstelle für DOS) |
| [`10_i-meic-pico_V6/10_KiCAD/`](10_i-meic-pico_V6/10_KiCAD/) | KiCAD-Projekt, Schaltplan, Layout, Gerber-Daten zur Leiterplatten-Fertigung |
| [`10_i-meic-pico_V6/20_Lazarus_PICO_i-meic-pico_V6_DOS/`](10_i-meic-pico_V6/20_Lazarus_PICO_i-meic-pico_V6_DOS/) | Quelltext der Pico-Firmware für den **ARM-Cross-Compiler** (Free Pascal / Lazarus). Die I/O-Schnittstelle ist hier für **DOS** ausgelegt. |
| [`60_FPC_Lazarus/`](60_FPC_Lazarus/) | Host-PC-Werkzeuge (Free Pascal / Lazarus) für Windows & Linux |
| [`60_FPC_Lazarus/20_LAZ_Console64_GUI64_Win64_Linux/`](60_FPC_Lazarus/20_LAZ_Console64_GUI64_Win64_Linux/) | **CONSOLE64** – Terminal-/Konsolen-Programm für alle i-meic (zentrales Werkzeug) |
| [`60_FPC_Lazarus/25_LAZ_CLI64_COM2INC/`](60_FPC_Lazarus/25_LAZ_CLI64_COM2INC/) | **COM2INC** – Kommandozeilen-Tool, das eine Binärdatei in ein Pascal-/NASM-Include (Byte-Array) wandelt |
| [`70_RON-BIOS-NASM_i-meic_WIN_Linux/`](70_RON-BIOS-NASM_i-meic_WIN_Linux/) | **RON-BIOS** – das 8086-BIOS in NASM-Assembler inkl. Build-Skripten |

> **Hinweis zur Nummerierung:** Die Präfixe `10_`, `60_`, `70_` lassen
> bewusst Lücken für weitere Module und Varianten (z. B. andere Konsolen,
> andere Betriebssystem-Varianten der Firmware), die nach und nach ergänzt
> werden.
>
> **Betriebssystem-Varianten der Firmware:** Für **dasselbe Board** gibt es
> mehrere Firmware-Varianten, die sich nur in der I/O-Schnittstelle
> unterscheiden – aktuell **DOS** (`…_DOS`) und **CP/M-86** (`…_CPM86`).
> Hardware und ARM-Cross-Compiler sind dabei identisch.

---

## Schnelleinstieg

### 1. Leiterplatte fertigen lassen
Die fertigen Gerber-Daten liegen unter
`10_i-meic-pico_V6/10_KiCAD/gerber_i-meic-pico_V6.zip` und können direkt bei
einem Leiterplattenhersteller hochgeladen werden. Schaltplan und Layout zur
Weiterentwicklung liegen im selben Ordner als KiCAD-Projekt.

### 2. BIOS bauen (optional, nur bei Änderungen)
Im Ordner `70_RON-BIOS-NASM_i-meic_WIN_Linux/`:
- Windows: `run_win.bat`
- Linux: `run_linux.sh`

Erzeugt `BIOS.BIN` und daraus per COM2INC die `BIOS.INC`.

### 3. Pico-Firmware bauen und flashen
Projekt `10_i-meic-pico_V6/20_Lazarus_PICO_i-meic-pico_V6_DOS/20_i-meic-pico_V6_DOS/imeic_dos.lpi`
in Lazarus öffnen, übersetzen und die erzeugte `imeic_dos.uf2` auf den
Raspberry Pi Pico kopieren (BOOTSEL-Modus).

### 4. Konsole starten und verbinden
`CONSOLE64` (im Ordner `60_FPC_Lazarus/20_LAZ_Console64_GUI64_Win64_Linux/bin/`)
starten, den richtigen COM-Port und 921600 Baud einstellen, dann den i-meic
mit Strom versorgen.

---

## Voraussetzungen

- **Hardware:** Intel 8086, 2× SRAM (512 KByte), Raspberry Pi Pico bzw.
  kompatibles RP2040-Modul (Footprints für mehrere Varianten vorhanden),
  serielle Verbindung zum Host
- **Software (Entwicklung):**
  - [KiCAD](https://www.kicad.org/) für die Hardware
  - [Lazarus / Free Pascal](https://www.lazarus-ide.org/) inkl.
    **ARM-Cross-Toolchain** für den RP2040 (der Pico ist ein
    ARM-Mikrocontroller); die Firmware läuft „bare-metal" auf dem Pico
  - RP2040-Bibliotheken von **Michael Ring** als Grundlage (im Ordner
    `units/` enthalten, **für dieses Projekt angepasst** – siehe Warnung
    unten), Original: <https://github.com/michael-ring/pico-fpcexamples>
  - [NASM](https://www.nasm.us/) für das BIOS (Binaries liegen bei)

---

## Danksagung / Drittanbieter

- Die Free-Pascal-Bibliotheken für den RP2040 stammen von **Michael Ring**:
  <https://github.com/michael-ring/pico-fpcexamples>. Sie waren eine
  **wichtige Grundlage** für diese Pico-/RP2040-Variante.
  ⚠️ Die im Ordner `units/` mitgelieferten Bibliotheken wurden für dieses
  Projekt **verändert und angepasst** und dürfen **nicht** durch die aktuelle
  Upstream-Version ersetzt werden (sonst Übersetzungsfehler).
- **NASM** wird für die Übersetzung des 8086-BIOS verwendet (siehe
  `LICENSE_NASM.TXT`).

---

## Lizenz

Dieses Projekt steht unter der **GNU General Public License v3.0** – siehe
[`LICENSE`](LICENSE). Das BIOS und COM2INC enthalten zusätzlich die
NASM-Lizenz (`LICENSE_NASM.TXT`) für die mitgelieferten NASM-Binaries.

---

## Sprache der Dokumentation

Diese README-Dateien sind zunächst auf **Deutsch** verfasst. Eine englische
Übersetzung ist geplant; die deutschen Fassungen werden dann z. B. als
`README_de.md` abgelegt.

<!--
TODO (vom Autor zu ergänzen):
- Autor / Kontakt / Projekt-Webseite
- Stückliste (BOM) zur Bestückung
- Foto des aufgebauten Boards
- genaue Pinbelegung Pico ↔ 8086 ↔ SRAM
-->
