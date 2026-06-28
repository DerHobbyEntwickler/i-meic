# 60_FPC_Lazarus — Host-PC-Werkzeuge (Free Pascal / Lazarus)

*(English version: [README.md](README.md))*


Dieser Ordner bündelt die **PC-Programme** rund um den i-meic, geschrieben in
**Free Pascal / Lazarus** und lauffähig unter **Windows 64-Bit und Linux**.
Sie laufen auf dem Host-Rechner, nicht auf dem i-meic selbst.

## Inhalt

| Unterordner | Programm | Zweck |
|-------------|----------|-------|
| [`20_LAZ_Console64_GUI64_Win64_Linux/`](20_LAZ_Console64_GUI64_Win64_Linux/) | **CONSOLE64** | Zentrales Terminal-/Konsolenprogramm. Stellt dem i-meic über die serielle Schnittstelle Bildschirm, Tastatur und Laufwerks-Images zur Verfügung. **Wird für alle i-meic benötigt.** |
| [`25_LAZ_CLI64_COM2INC/`](25_LAZ_CLI64_COM2INC/) | **COM2INC** | Kommandozeilen-Werkzeug, das eine Binärdatei (z. B. das BIOS) in ein Pascal-/NASM-Include mit einem Byte-Array umwandelt. |

## Hinweis zu den Konsolen

CONSOLE64 ist die hier abgelegte Konsole – es **gibt mehrere Konsolen** für
unterschiedliche i-meic-Varianten, die nach und nach ergänzt werden. Die
Nummerierung (`20_`, `25_`, …) lässt dafür bewusst Platz.

## Bauen

Alle Programme lassen sich mit **Lazarus** über die jeweilige `*.lpi`-Datei
öffnen und übersetzen. Vorkompilierte Binaries (`.exe` für Windows, die
ausführbare Datei ohne Endung für Linux) liegen zur direkten Nutzung bei.
