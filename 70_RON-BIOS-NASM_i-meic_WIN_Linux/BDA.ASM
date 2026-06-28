
; ******************************
; ***  BDA - BIOS-Data_Area  ***
; ******************************


BIOS_DATA_AREA:


;0400H (4 words)  IO ports for COM1-COM4 serial (each address is 1 word, zero if none)
;  40:00  word  COM1 port address
;  40:02  word  COM2 port address
;  40:04  word  COM3 port address
;  40:06  word  COM4 port address

    DW 0000H
    DW 0000H
    DW 0000H
    DW 0000H


;0408H (4 words)  IO ports for LPT1-LPT4 parallel (each address is 1 word, zero if none)
;  40:08  word  LPT1 port address
;  40:0A  word  LPT2 port address
;  40:0C  word  LPT3 port address
;  40:0E  word  LPT4 port address (except PS/2)

    DW 0000H
    DW 0000H
    DW 0000H
    DW 0000H


;0410H (word) (Equip Flag) packed bit flags for detected hardware
; 2 drives, 80x25 color, no coprocessor

;    |F|E|D|C|B|A|9|8|7|6|5|4|3|2|1|0|  AX
;     | | | | | | | | | | | | | | | `---- IPL diskette installed
;     | | | | | | | | | | | | | | `----- math coprocessor
;     | | | | | | | | | | | | `-------- old PC system board RAM < 256K
;     | | | | | | | | | | | | | `----- pointing device installed (PS/2)
;     | | | | | | | | | | | | `------ not used on PS/2
;     | | | | | | | | | | `--------- initial video mode
;     | | | | | | | | `------------ # of diskette drives, less 1
;     | | | | | | | `------------- 0 if DMA installed
;     | | | | `------------------ number of serial ports
;     | | | `------------------- game adapter installed
;     | | `-------------------- unused, internal modem (PS/2)
;     `----------------------- number of printer ports
;
; Wichtiger Hinweis: 
; Sind 2 Diskettenlaufwerke installiert, dann
; muessen diese dem DOS mitgeteilt werden (Bit 7 und 6)
;      FEDCBA9876543210
    DW 0000000000100001B ; 


;0412H (byte)  Interrupt flag - Manufacturing test
    DB 00H


;0413H (word)  Memory Size
; 280H im Referenzsystem
    DW 0280H   ;280H = 640KB


;0415H (word)  IO-RAM Size
    DW 0000H


;0x0417 (byte)  keyboard state flag 0
    DB 00H


;0x0418 (byte)  keyboard state flag 1
    DB 00H


;0x0419 (byte)  ALT_INPUT
    DB 00H


;0x041A (word)  keyboard head 
;    DW 001EH
    DW 0034H

;0x041C (word)  keyboard tail
;    DW 001EH 
    DW 0034H

;0x041E (32 bytes)  keyboard buffer
    DB 00H, 00H, 00H, 00H
    DB 00H, 00H, 00H, 00H
    DB 00H, 00H, 00H, 00H
    DB 00H, 00H, 00H, 00H
    DB 00H, 00H, 00H, 00H
    DB 00H, 00H, 00H, 00H
    DB 00H, 00H, 00H, 00H
    DB 00H, 00H, 00H, 00H


;0x043E  DISKETTE DATA AREAS
    DB 00H, 00H, 00H, 00H
    DB 00H, 00H, 00H, 00H
    DB 00H, 00H, 00H



; -------------------------------------------
;     VIDEO
; Grafik-Adapter-Informationen
; -------------------------------------------
;
;40:49  byte    Current video mode
;0449H (byte) Display Mode [VIDEO DISPLAY DATA AREA]
    DB 003H ; 3 = 80 x 25 text (16 color)


;40:4A  word    Number of screen columns
;044AH (word)  number of columns in text mode
    DW 0050H ; -> 80 Spalten


;40:4C  word    Size of current video regen buffer in bytes
;044CH (word)
    DW 1000H ; page_size


;40:4E  word    Offset of current video page in video regen buffer
;044EH (word)
    DW 0000H


;40:50  8 words Cursor position of pages 1-8, high order byte=row
;               low order byte=column; changing this data isn't
;               reflected immediately on the display
;0450H (16 BYTE AS WORD)  :CURSOR_POSN 8 PAGES   col, row
; Cursorpositionen f r die Seiten 0-7, abwechselnd Spalte und Zeile
    DW 0000H, 0000H
    DW 0000H, 0000H
    DW 0000H, 0000H
    DW 0000H, 0000H


;0460H (word)  Cursor Mode
    DW 0000H


;40:62  byte    Active display page number
;0462H  Active Page
    DB 00H


;40:63  word    Base port address for active 6845 CRT controller
;               3B4h = mono, 3D4h = color
;0463H (2 bytes, taken as a word)  base IO port for video
    DB 00H
    DB 00H


;40:65  byte    6845 CRT mode control register value (port 3x8h)
;               EGA/VGA values emulate those of the MDA/CGA
;0465H (byte)
    DB 00H

;40:66  byte    CGA current color palette mask setting (port 3d9h)
;               EGA and VGA values emulate the CGA
;0466H (byte)
    DB 00H


;0x0467 (word)
    DW 0000H


;0x0469 (word)
    DW 0000H


;0x046B	(byte)
    DB 00H

;0x046C (word)  # of IRQ0 timer ticks since boot
; Daily timer counter, equal to zero at midnight;
; incremented by INT 8; read/set by INT 1A
; Zähler für Interrupt 0x1A
    DW 0000H
    DW 0000H
;0470H
; Clock rollover flag, set when 40:6C exceeds 24hrs
    DB 00H


;0471H
; BIOS break flag, bit 7 is set if Ctrl-Break was
; *ever* hit; set by INT 9
    DB 00H

;0472H
; Soft reset flag via Ctl-Alt-Del or JMP FFFF:0
;   1234h  Bypass memory tests & CRT initialization
;   4321h  Preserve memory
;   5678h  System suspend
;   9ABCh  Manufacturer test
;   ABCDh  Convertible POST loop
;   ????h  many other values are used during POST
    DW 1234H ; soft_rst_flg


;0474H
; Status of last hard disk operation (see INT 13,1)
    DB 00H


;0x0475 (byte)  # of hard disk drives detected
    DB 00H


;LATER 0x0476
    DB 00H
    DB 00H
    DD 00H
    DD 00H



;0x0480 (word)  keyboard buffer start
    DW 001EH


;0x0482 (word)  keyboard buffer end
    DW 003EH

;0x0484 (byte)
; vid_rows db 25 ; at 40:84
    DB 25

;LATER 0x0485
    DB 00H, 00H, 00H
    DB 00H, 00H, 00H, 00H
    DB 00H, 00H, 00H, 00H
    DB 00H, 00H, 00H, 00H
    DB 00H, 00H, 00H


;0x0497 (byte)  last keyboard LED/Shift key state
    DB 00H

; 498
    DB 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
    DB 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
    DB 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
    DB 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
    DB 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
    DB 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
    DB 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
    DB 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
    DB 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
    DB 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
    DB 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
    DB 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
    DB 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H


BIOS_DATA_AREA_END:
