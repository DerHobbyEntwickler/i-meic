# 20_LAZ_Console64_GUI64_Win64_Linux — CONSOLE64

*(English version: [README.md](README.md))*


**CONSOLE64** ist das zentrale Host-Programm für den i-meic. Es verbindet
sich über die serielle Schnittstelle mit dem Board und stellt ihm die
gesamte „sichtbare" Peripherie bereit:

- **Bildschirm / Video-Terminal** (mit Codepage-437-Zeichensatz)
- **Tastatur**
- **Laufwerke** als Disk-Images (Diskette und Festplatte)

Ohne diese Konsole hat der i-meic weder Anzeige noch Eingabe – sie wird
daher **für alle i-meic benötigt**. Lauffähig unter **Windows 64-Bit und
Linux** (GUI-Anwendung auf LCL-Basis).

## Ordnerstruktur

| Ordner / Datei | Bedeutung |
|----------------|-----------|
| `bin/CONSOLE64.exe` | Ausführbares Programm (Windows). |
| `bin/CONSOLE64` | Ausführbares Programm (Linux). |
| `bin/CONSOLE64.ini` | Konfiguration: COM-Port, Baudrate, Schrift, Sprache, Logging. |
| `bin/IMAGE_FDD/BOOTA.IMG` | Disketten-Image (1,44 MB) – Laufwerk A:. |
| `bin/IMAGE_HDD/BOOTC.IMG` | Festplatten-Image (8 MB) – Laufwerk C:. |
| `src/` | Lazarus-Quelltext. |

### Wichtige Quelldateien (`src/`)

| Datei | Inhalt |
|-------|--------|
| `CONSOLE64.lpi` / `.lpr` | Lazarus-Projekt und Hauptprogramm. |
| `MainUnit.pas` / `.lfm` | Hauptfenster und Programmlogik. |
| `Unit_CONS.pas` / `.lfm` | Konsolen-/Terminal-Fenster. |
| `Video_Send.INC` | Aufbereitung der Videoausgabe zum/vom i-meic. |
| `Codepage437.INC` | DOS-Zeichensatz (Codepage 437). |
| `Keyboard.INC` | Tastaturbehandlung. |
| `language_u.pas`, `language_de.INC`, `language_en.INC` | Mehrsprachigkeit (Deutsch/Englisch). |
| `synaser/` | Serielle Bibliothek (Synaser) für die COM-Port-Kommunikation. |
| `windos.pas` | Hilfsroutinen. |

## Bedienung

1. Programm starten (`CONSOLE64.exe` bzw. `./CONSOLE64`).
2. In den Einstellungen den richtigen **COM-Port** und die **Baudrate**
   wählen. Die Baudrate muss mit der Firmware übereinstimmen
   (Standard der Firmware: **921600 Baud**).
3. Bei Bedarf die Disk-Images in `IMAGE_FDD/` bzw. `IMAGE_HDD/` zuordnen.
4. Den i-meic mit Strom versorgen – die Konsole zeigt die Ausgabe an und
   leitet Tastatureingaben weiter.

Die Einstellungen werden in `CONSOLE64.ini` gespeichert.

> **Tipp:** Eigene DOS-Disketten/Festplatten lassen sich durch Austauschen
> der `BOOTA.IMG` / `BOOTC.IMG` einbinden (gleiche Image-Größe beibehalten).
