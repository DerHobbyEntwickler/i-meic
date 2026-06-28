# 10_KiCAD — Hardware-Design des i-meic-Boards (KiCAD)

*(English version: [README.md](README.md))*


Hier liegen alle Dateien, um die Leiterplatte des i-meic **fertigen zu
lassen** und um die Hardware **selbst weiterzuentwickeln**.

## Wichtigste Dateien

| Datei / Ordner | Zweck |
|----------------|-------|
| `gerber_i-meic-pico_V6.zip` | **Fertigungsdaten (Gerber + Bohrdaten).** Direkt beim Leiterplattenhersteller hochladbar. |
| `i-meic-pico_V6.pdf` | Schaltplan / Layout als PDF zum Ansehen und Drucken. |
| `i-meic-pico_V6.svg` | Vektor-Ansicht des Boards. |
| `i-meic-pico_V6.jpg` | Bild des Boards zur schnellen Übersicht. |
| `i-meic-pico_V6/` | Das eigentliche **KiCAD-Projekt** (siehe unten). |

## KiCAD-Projektordner `i-meic-pico_V6/`

| Datei | Bedeutung |
|-------|-----------|
| `i-meic-pico_V6.kicad_pro` | KiCAD-Projektdatei (hiermit das Projekt öffnen). |
| `i-meic-pico_V6.kicad_sch` | Schaltplan. |
| `i-meic-pico_V6.kicad_pcb` | Platinen-Layout. |
| `i-meic-pico_V6.kicad_prl` | Lokale Projekteinstellungen. |
| `board-library/` | **Projekteigene Bauteil-Bibliothek** mit Symbolen (`.kicad_sym`) und Footprints (`.pretty/*.kicad_mod`) – u. a. für RP2040-Module, SRAM, LCDs, ITP3-Stecker, Schalter und mehr. |

## Leiterplatte fertigen lassen

1. `gerber_i-meic-pico_V6.zip` unverändert beim Leiterplattenhersteller
   hochladen.
2. Übliche Parameter wählen (z. B. 2 Lagen, 1,6 mm, HASL/ENIG).
3. Nach Erhalt der Platine gemäß Schaltplan bestücken.

## Weiterentwickeln

Das Projekt mit **KiCAD** über `i-meic-pico_V6.kicad_pro` öffnen. Damit die
projekteigenen Bauteile korrekt geladen werden, sollte der Ordner
`board-library/` als Bibliothekspfad relativ zum Projekt erhalten bleiben.

> **TODO (zu ergänzen):** Stückliste (BOM), Bestückungsplan und die genaue
> Pinbelegung Pico ↔ 8086 ↔ SRAM erleichtern den Nachbau erheblich.
