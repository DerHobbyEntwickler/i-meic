# 25_LAZ_CLI64_COM2INC — COM2INC

*(English version: [README.md](README.md))*


**COM2INC** ist ein kleines Kommandozeilen-Werkzeug (Free Pascal / Lazarus),
das eine **Binärdatei in ein Include-File mit einem Byte-Array** umwandelt.
Damit lässt sich z. B. das fertige BIOS-Binär (`BIOS.BIN`) als Pascal-Array
in die Pico-Firmware einbetten.

Lauffähig unter **Windows 64-Bit und Linux**.

## Funktion

```
COM2INC  <Eingabe.BIN>  <Ausgabe.INC>  <Längen-Konstante>  <Array-Name>  [CLEAR]
```

| Parameter | Bedeutung |
|-----------|-----------|
| `Eingabe.BIN` | beliebige Binärdatei (z. B. `BIOS.BIN`, `CPD5.COM`). |
| `Ausgabe.INC` | erzeugtes Include mit dem Byte-Array. |
| `Längen-Konstante` | Name der erzeugten Längenkonstante (z. B. `Laenge_BIOS_Array`). |
| `Array-Name` | Name des erzeugten Arrays (z. B. `BIOS_ARR`). |
| `CLEAR` | optional; bereinigt/initialisiert die Ausgabe. |

**Beispiel** (siehe `run_win.bat`):

```
COM2INC.exe CPD5.COM CPD5.INC Laenge_BIOS_Array BIOS_ARR CLEAR
```

Ergebnis ist eine `.INC`-Datei der Form
`BIOS_ARR : array[0..Laenge_BIOS_Array] of Byte = ( … );`, die per
`{$I …}` in den Pascal-Quelltext eingebunden werden kann.

## Inhalt des Ordners

| Datei | Bedeutung |
|-------|-----------|
| `COM2INC.lpi` / `.lpr` | Lazarus-Projekt und Quelltext. |
| `COM2INC.exe` | Ausführbares Programm (Windows). |
| `COM2INC` | Ausführbares Programm (Linux). |
| `CPD5.COM` / `CPD5.INC` | Beispiel: Eingabe-Binär und erzeugtes Include. |
| `run_win.bat` / `run_linux.sh` | Aufruf-Beispiele für Windows bzw. Linux. |
| `LICENSE_NASM.TXT` | Lizenz der mitgelieferten NASM-Komponenten. |

## Bezug zum BIOS

Dasselbe Werkzeug wird im Ordner `70_RON-BIOS-NASM_i-meic_WIN_Linux/`
verwendet, um aus `BIOS.BIN` die `BIOS.INC` für die Firmware zu erzeugen.
