# 10_i-meic-pico_V6 — Das i-meic-Board (Hardware & Firmware)

*(English version: [README.md](README.md))*


Dieser Ordner enthält **eine vollständige i-meic-Variante**: die Hardware
(KiCAD) und die dazu passende Pico-Firmware für den DOS-Betrieb.

Der Zusatz **`pico_V6`** bezeichnet die Hardware-Revision 6 des Boards, bei
der die gesamte I/O über einen **Raspberry Pi Pico (RP2040)** läuft.

## Inhalt

| Unterordner | Beschreibung |
|-------------|--------------|
| [`10_KiCAD/`](10_KiCAD/) | KiCAD-Projekt: Schaltplan, Platinen-Layout, Gerber-Daten und Bauteil-Bibliothek. Hier kann die Leiterplatte in Auftrag gegeben **und** weiterentwickelt werden. |
| [`20_Lazarus_PICO_i-meic-pico_V6_DOS/`](20_Lazarus_PICO_i-meic-pico_V6_DOS/) | Quelltext der **Pico-Firmware** für den **ARM-Cross-Compiler** (Free Pascal / Lazarus, „bare-metal" auf dem RP2040). Die I/O-Schnittstelle ist hier für **DOS** ausgelegt. Erzeugt die `imeic_dos.uf2` zum Flashen des Pico. |

> **Zur Namensgebung des Firmware-Ordners:** `Lazarus_PICO` steht für den
> Free-Pascal-/Lazarus-**Cross-Compiler für den ARM-Kern** des RP2040 (der
> Pico ist ein ARM-Mikrocontroller, kein x86). Der Zusatz `…_DOS` bezieht
> sich auf die **Funktionalität der I/O-Schnittstelle** für den SBC, die für
> DOS erstellt ist.
>
> **Weitere Betriebssystem-Variante (gleiches Board):** Für dasselbe Board
> existiert eine Version mit I/O-Schnittstelle für **CP/M-86**
> (`Lazarus_PICO_i-meic-pico_V6_CPM86`). Hardware und ARM-Cross-Compiler
> bleiben gleich, nur die I/O-Funktionalität ist auf das jeweilige
> Betriebssystem zugeschnitten.

## Zusammenspiel

Die Hardware aus `10_KiCAD` und die Firmware aus
`20_Lazarus_PICO_i-meic-pico_V6_DOS` gehören direkt zusammen:

1. Die Leiterplatte wird nach den KiCAD-/Gerber-Daten gefertigt und bestückt.
2. Die Firmware wird übersetzt und auf den Raspberry Pi Pico geflasht.
3. Der Pico lädt beim Start das BIOS in den SRAM, taktet die 8088-CPU und
   bedient deren gesamte I/O.

Bildschirm, Tastatur und Laufwerke werden über die serielle Schnittstelle
vom Host-Programm **CONSOLE64**
(`60_FPC_Lazarus/20_LAZ_Console64_GUI64_Win64_Linux/`) bereitgestellt.

> Das hier verwendete BIOS wird aus dem Ordner
> `70_RON-BIOS-NASM_i-meic_WIN_Linux/` gebaut und als `BIOS.INC` in die
> Firmware eingebettet.
