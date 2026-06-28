
BITS 16
CPU 8086


BIOS_Segment   EQU 0F800H
; BIOS_Segment   EQU 0FE00H
BIOS_Stack     EQU 0FF00H



%define TRUE        -1
%define FALSE       0


; Assembler Pseudo-Code
; %define DEBUG_MSG   TRUE
%define DEBUG_MSG    FALSE 

; %define DEBUG_INT10 TRUE  
%define DEBUG_INT10 FALSE

%define ERROR_MSG   TRUE
; %define ERROR_MSG   FALSE  



; **********************************************************
;         Vereinbarungsteil fuer die i-meic Hardware
; **********************************************************


AUSGANG          EQU    0   ; IO-Port fuer die Ausgabe zum ATMEGA32


; Befehlscode fuer IORQ
IORQ_LED_Ein     EQU  01
IORQ_LED_Aus     EQU  02
IORQ_CONIN       EQU  04
IORQ_CONST       EQU  05

IORQ_READ        EQU  07
IORQ_WRITE       EQU  08
IORQ_LIST        EQU  09
IORQ_TIME        EQU  10
IORQ_SOUND       EQU  11

IORQ_LW_COUNT    EQU  12 ; Abfrage der Anzahl der FDD und HDD
IORQ_LW_SHOW     EQU  14 ; Anzeige der FDD und HDD

IORQ_READ_FAT12  EQU  15
IORQ_WRITE_FAT12 EQU  16

IORQ_STHD        EQU  17
IORQ_DEBUG       EQU  18

IORQ_VIDEO_SEND  EQU  20
IORQ_VIDEO_RESV  EQU  21

IORQ_VIDEO_SA_Teil  EQU  24
IORQ_VIDEO_SysTick  EQU  25

IORQ_START_SysTick  EQU  26  

IORQ_MOUSE          EQU  27

IORQ_READ_BIOS      EQU  28
IORQ_WRITE_BIOS     EQU  29

IORQ_READ_DevList   EQU  30


 








; ---------------------------------------

; BIOS-Code startet ab F800:0000H (F80000H)

ORG 0000H  ; 

; ---------------------------------------

    JMP    BIOS_START

    DB  'IBM COMPATIBLE BIOS for i-meic',00

BIOS_VECTOR_TABLE:                ; 10 Byte
    DB  00,00,00,00,00,00,00,00,00,00  ; 

DEVICE_LIST:                      ; 16+2+24=42 Byte
    DB  00,00,00,00,00,00,00,00   ; HDD_Tabelle : Array [0..15] of Byte;
    DB  00,00,00,00,00,00,00,00
    DB  00,00                     ; FDD_LW_A, FDD_LW_B : Byte;
    DB  00,00,00,00,00,00,00,00   ;
    DB  00,00,00,00,00,00,00,00
    DB  00,00,00,00,00,00,00,00 


    DB  00,00,00,00,00            ; Reserve



BIOS_START:

; kein Interrupt, Bemerkung: der i-meic ist ein absolutes Minimal-System nur mit CPU und Speicher
; die sehr aufwendige Hardware fuer maskierbare Interrupts ist nicht vorhanden
; daher wird beim i-meic niemals SLI gesetzt
    CLI




; kein Interrupt, Bemerkung: der i-meic ist ein absolutes Minimal-System nur mit CPU und Speicher
; die sehr aufwendige Hardware fuer maskierbare Interrupts ist nicht vorhanden
; daher wird beim i-meic niemals SLI gesetzt
    CLI


; Setzen des Stack-Segmentes
    MOV    AX, CS       
    MOV    DS, AX          
    MOV    ES, AX          
    ;


; Setzen des Stack-Segmentes
; auf 0FF00H:0000H = 0FF000H
; etwa 28KB - 6KB (BIOS) = 22KB fuer Stack verfuegbar
    MOV    AX, BIOS_Stack
    MOV    SS, AX
    MOV    SP, 0



; ... zuerst wird die gesammter Interrupt-Vektor-Tabelle von 0000:0000H
; bis 0000:03FFH mit einem Dummy-Wert geladen
    CALL   INIT_ALL_IVT


; dann wird die eigene Interrupt-Vektor-Tabelle eingeschrieben ...
; Lade der Interrupt-Vektor-Tabelle auf 0000:0000H
    CALL   LOAD_INT_VECTOR_TABLE  ;COPIES INTERRUPT VECTOR TABLE TO ADDRESS 0000:0000H



; Lade des BIOS-Daten-Bereiches auf 0000:0400H
    CALL   LOAD_BIOS_DATA_AREA    ;COPIES BIOS DATA TO ADDRESS 0X0000:0X0400


; Laden des Interrupt-Vektors fuer den Interrupt 33H (Maus-Interrupt)
; auf die Adresse 0000:00CCH
    CALL   LOAD_BIOS_INT33H



; Loeschen des VIDEO-RAMS
    CALL   CLEAR_VIDEO_RAM


; Ausgabe erste BIOS-Meldung
    MOV   BX, BIOS_Start_Meldung
    CALL  TEXT_TO_CONOUT




; ******************************************
; ** Initialisierung einiger Hardwareteile
; ******************************************




; Einlesen der Uhrzeit von der CONSOLE64
;
    CALL  READ_DATE_TIME_DEVICE

; startet den Counter fuer den NMI-Port,
; der den SysTick ausloest, INT02 -> INT08 -> INT1A
;
    CALL  Start_SysTick




; Abfrage der Anzahl der FDD und HDD und Einschreiben
; der Werte in DISK_FDD_CNT und DISK_HDD_CNT (INT13.ASM)
;
    CALL  DISK_COUNT
    CALL  FDD_TO_CONOUT
    CALL  HDD_TO_CONOUT



; Anzeige der verfuegbaren FDD und HDD durch den uC
; an CONOUT (TEXT-VIDEO)
    CALL   DISK_SHOW


; Eintragen der FDD in BDA Equpment-Word (410H)
    CALL   FDD_IN_EQUIP
;    CALL   EQUIP_TO_CONOUT

; ******************************************





; Laden des Boot-Sektors (MBR) auf 7C00H (DOS-Standard)

    MOV AX, 07C0H   ; 07C0:0000
    MOV ES, AX      ; ES:BX = ADDRESS BUFFER
    
    MOV AX, 0201H   ; READ 1 SECTOR
    MOV BX, 0000H   ; ES:BX = ADDRESS BUFFER
    MOV CX, 0001H   ; SECTOR
    MOV DX, 0000H   ; HEAD=0, DRIVE 0=A
    INT 13H         ; INT 13





    MOV   BX, Start_Boot_Loader
    CALL  TEXT_TO_CONOUT



    MOV AX, 07C0H   ;SEGMENT
    MOV DS, AX      ;SET DS
    MOV ES, AX      ;SET ES
    MOV SS, AX      ;SET SS



    MOV SP, 0FFFEH  ;SET SP
    MOV AX, 00000H  ;ZERO AX
    MOV BX, 00000H  ;ZERO BX
    MOV CX, 00000H  ;ZERO CX
    MOV DX, 00000H  ;ZERO DX



;   JMP FAR 007C0:00000
    db 0EAH,000,000,0C0H,007H ; Ersatzloesung, sonst Fehlermeldung im MASM




; ****************************************************

;-------------------------------------------------
; Common Handler (z.B. im eigenen Code-Segment)
;-------------------------------------------------

COMMON_HANDLER:

%if ERROR_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,0FFH
    CALL   DEBUG_TRACE_UNSUPPORTED
    POP    BP
    POP    AX
%endif

    IRET    ;RETURN FROM INTERRUPT

;-------------------------------------------------
; Initialisierung: alle IVT-Einträge umbiegen
;-------------------------------------------------
INIT_ALL_IVT:

    XOR  AX, AX          ; AX=0
    MOV  ES, AX          ; ES = 0000h -> IVT-Segment

    ; Adresse des Common Handlers holen
    MOV  AX, BIOS_Segment
    MOV  DX, COMMON_HANDLER

    XOR  DI, DI          ; DI = 0 -> erster Eintrag (INT 00h)
    MOV  CX, 256         ; 256 Vektoren (Laenge)

SET_NEXT_VECTOR:

    MOV  [es:DI], DX     ; Offset
    MOV  [es:DI+2], AX   ; Segment
    ADD  DI, 4           ; nächster Vektor
    LOOP  SET_NEXT_VECTOR

    RET





; ****************************************************



; Laden der Interrupt-Vektor-Tabelle an die Adresse 0000:0000
LOAD_INT_VECTOR_TABLE:
    CLD
    MOV AX, 00000
    MOV ES, AX
    MOV DI, 00000
    MOV AX, CS
    MOV DS, AX
    MOV SI, INT_VECTOR_TABLE
    MOV CX, INT_VECTOR_TABLE_END - INT_VECTOR_TABLE
    REP MOVSB
    RET



; kopieren des BIOS-DATA-AREA (BDA) an die Adresse 0040:0000
LOAD_BIOS_DATA_AREA:
    CLD
    MOV AX, 0040H
    MOV ES, AX
    MOV DI, 0000H
    MOV AX, CS
    MOV DS, AX
    MOV SI, BIOS_DATA_AREA
    MOV CX, BIOS_DATA_AREA_END - BIOS_DATA_AREA
    REP MOVSB
    RET





; ****************************************************



; Laden des Interrupt-Vektors-an die Adresse 0000:00CC
;
LOAD_BIOS_INT33H:
    XOR  AX, AX          ; AX=0
    MOV  ES, AX          ; ES = 0000h -> IVT-Segment

    ; Adresse des Common Handlers holen
    MOV  AX, BIOS_Segment
    MOV  DX, INT_33

    MOV  DI, 00CCH       ; 

    MOV  [es:DI], DX     ; Offset
    MOV  [es:DI+2], AX   ; Segment

    RET






; ****************************************************

; ---------------------------------------

BIOS_Start_Meldung:
    DB 0CH, 'BIOS 2.0 fuer i-meic (c) by Ronald Daleske 08/2025', 0DH, 0AH, 0  ; BIOS-Start Meldung

; ---------------------------------------

Start_Boot_Loader:
    DB 0DH, 0AH,'Start Boot-Loader', 0DH, 0AH, 0  ; Boot-Loader Meldung
Boot_Loader_Ende:







;**********************
;**  BIOS DATA AREA  **
;**********************

%include "BDA.ASM"

; --------------------------



INT_VECTOR_TABLE:
    DW INT_00, BIOS_Segment
    DW INT_01, BIOS_Segment
    DW INT_02, BIOS_Segment
    DW INT_03, BIOS_Segment
    DW INT_04, BIOS_Segment
    DW INT_05, BIOS_Segment
    DW INT_06, BIOS_Segment
    DW INT_07, BIOS_Segment
    DW INT_08, BIOS_Segment
    DW INT_09, BIOS_Segment
    DW INT_0A, BIOS_Segment
    DW INT_0B, BIOS_Segment
    DW INT_0C, BIOS_Segment
    DW INT_0D, BIOS_Segment
    DW INT_0E, BIOS_Segment
    DW INT_0F, BIOS_Segment
    DW INT_10, BIOS_Segment
    DW INT_11, BIOS_Segment
    DW INT_12, BIOS_Segment
    DW INT_13, BIOS_Segment
    DW INT_14, BIOS_Segment
    DW INT_15, BIOS_Segment
    DW INT_16, BIOS_Segment
    DW INT_17, BIOS_Segment
    DW INT_18, BIOS_Segment
    DW INT_19, BIOS_Segment
    DW INT_1A, BIOS_Segment
    DW INT_1B, BIOS_Segment
    DW INT_1C, BIOS_Segment
    DW INT_1D, BIOS_Segment
    DW INT_1E, BIOS_Segment
    DW INT_1F, BIOS_Segment
INT_VECTOR_TABLE_END:



INT_00: ;Divide by Zero

%if ERROR_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,00H
    CALL   DEBUG_TRACE_UNSUPPORTED
    POP    BP
    POP    AX
%endif

    IRET    ;RETURN FROM INTERRUPT



INT_01: ;Single Step

%if ERROR_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,01H
    CALL   DEBUG_TRACE_UNSUPPORTED
    POP    BP
    POP    AX
%endif

    IRET    ;RETURN FROM INTERRUPT






; *******************************************
; * INT 02 - NMI SysTick Hardware-Interrupt * 
; *******************************************
;

%include "INT02.ASM"

; --------------------------



INT_03: ;Breakpoint

%if ERROR_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,03H
    CALL   DEBUG_TRACE_UNSUPPORTED
    POP    BP
    POP    AX
%endif

    IRET    ;RETURN FROM INTERRUPT



INT_04: ;Overflow

%if ERROR_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,04H
    CALL   DEBUG_TRACE_UNSUPPORTED
    POP    BP
    POP    AX
%endif

    IRET    ;RETURN FROM INTERRUPT



INT_05: ;Print Screen

%if ERROR_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,05H
    CALL   DEBUG_TRACE_UNSUPPORTED
    POP    BP
    POP    AX
%endif

    IRET    ;RETURN FROM INTERRUPT



INT_06: ;Reserved

%if ERROR_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,06H
    CALL   DEBUG_TRACE_UNSUPPORTED
    POP    BP
    POP    AX
%endif

    IRET    ;RETURN FROM INTERRUPT




INT_07: ;Reserved

%if ERROR_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,07H
    CALL   DEBUG_TRACE_UNSUPPORTED
    POP    BP
    POP    AX
%endif

    IRET    ;RETURN FROM INTERRUPT




; **************************
; * INT 08
; **************************
;This is the real time clock interrupt.
%include "INT08.ASM"

; --------------------------



INT_09: ;This is the Keyboard interrupt.
; Der Hardware-Keyboard-IRQ (INT 09H) ist komplett leer (nur Debug-Ausgabe). 
; Auf einem PC-kompatiblen System ist INT 09H für die Tastaturverarbeitung zuständig. 
; Auf dem i-meic wird die Tastatur über INT 16H / IORQ_CONIN gepollt.

%if ERROR_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,09H
    CALL   DEBUG_TRACE_UNSUPPORTED
    POP    BP
    POP    AX
%endif

    IRET    ;RETURN FROM INTERRUPT



INT_0A: ;Reserved

%if ERROR_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,0AH
    CALL   DEBUG_TRACE_UNSUPPORTED
    POP    BP
    POP    AX
%endif

    IRET    ;RETURN FROM INTERRUPT



INT_0B: ;Communications

%if ERROR_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,0BH
    CALL   DEBUG_TRACE_UNSUPPORTED
    POP    BP
    POP    AX
%endif

    IRET    ;RETURN FROM INTERRUPT



INT_0C: ;Communications

%if ERROR_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,0CH
    CALL   DEBUG_TRACE_UNSUPPORTED
    POP    BP
    POP    AX
%endif

    IRET    ;RETURN FROM INTERRUPT




INT_0D: ;Disk

%if ERROR_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,0DH
    CALL   DEBUG_TRACE_UNSUPPORTED
    POP    BP
    POP    AX
%endif

    IRET    ;RETURN FROM INTERRUPT




INT_0E: ; ???

%if ERROR_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,0EH
    CALL   DEBUG_TRACE_UNSUPPORTED
    POP    BP
    POP    AX
%endif

    IRET    ;RETURN FROM INTERRUPT




INT_0F: ;Printer

%if ERROR_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,0FH
    CALL   DEBUG_TRACE_UNSUPPORTED
    POP    BP
    POP    AX
%endif

    IRET    ;RETURN FROM INTERRUPT




; **************************
; * INT 10
; **************************

%include "INT10.ASM"

; --------------------------



; ******************************************
; ***   INT 11 - Hardwarekonfiguration   ***
;      Es sind keine Register zu setzen
; ******************************************
INT_11: ;Equipment Check

%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,11H
    CALL   DEBUG_TRACE_ENTRY
    POP    BP
    POP    AX
%endif

    PUSH  DS          ;STORE DS
    PUSH  BX          ;STORE BX
    MOV   AX,0040H     ;BIOS DATA AREA
    MOV   DS,AX        ;SET DATA SEGMENT
    MOV   BX,0010H     ;OFFSET 10H EQUIPMENT LIST
    MOV   AX,[ds:BX]   ;STORE EQUPMENT LIST AX
    POP   BX           ;RESTORE BX
    POP   DS           ;RESTORE DS

%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,11H
    CALL   DEBUG_TRACE_RETURN
    POP    BP
    POP    AX
%endif

    IRET    ;RETURN FROM INTERRUPT




; ******************************************
; ***  INT 12 -  Speichergröße ermitteln ***
;      Es sind keine Register zu setzen
; ******************************************
INT_12: ;Memory

%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,12H
    CALL   DEBUG_TRACE_ENTRY
    POP    BP
    POP    AX
%endif

    PUSH  DS           ;STORE DS
    PUSH  BX           ;STORE BX
    MOV   AX,0040H     ;BIOS DATA AREA
    MOV   DS,AX        ;SET DATA SEGMENT
    MOV   BX,0013H     ;OFFSET 13H FOR MEMORY SIZE
    MOV   AX,[ds:BX]   ;STORE MEMORY SIZE AX
    POP   BX           ;RESTORE BX
    POP   DS           ;RESTORE DS

%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,12H
    CALL   DEBUG_TRACE_RETURN
    POP    BP
    POP    AX
%endif

    IRET    ;RETURN FROM INTERRUPT




; **************************
; * INT 13
; **************************

%include "INT13.ASM"

; --------------------------



; *****************************************************
; ***   INT 14 - Initialize and Access Serial Port  ***
; *****************************************************
INT_14: 

    CMP AH,000H        ;Get System Configuration
    JZ INT14_AH_00

%if ERROR_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,14H
    CALL   DEBUG_TRACE_UNSUPPORTED
    POP    BP
    POP    AX
%endif

    IRET    ;RETURN FROM INTERRUPT




; ****************************************
; Funktion 00H: Initialize And Access Serial Communications Port
;
; Eingabe: AH=00H (Init V24)
;          AL=Initialisierungswerte
;          DX=Schnittstellen-Nummer
;
; Ausgabe: AX=Statuswort
;
; ****************************************
INT14_AH_00:

%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,14H
    CALL   DEBUG_TRACE_ENTRY
    POP    BP
    POP    AX
%endif

    MOV    AX,6000H       ; 


    IRET    ;RETURN FROM INTERRUPT



; ****************************
; ***   INT 15 - Cassette  ***
; ****************************
INT_15:

    CMP AH,041H        ; Wait on External Event
    JZ INT15_AH_41


    CMP AH,088H        ; Extended Memory Size
    JZ INT15_AH_88


    CMP AH,0C0H        ; Get System Configuration
    JZ INT15_AH_C0



%if ERROR_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,15H
    CALL   DEBUG_TRACE_UNSUPPORTED
    POP    BP
    POP    AX
%endif


    MOV    AH,86H       ; Funktion fehlt
    MOV    AL,00H       ; Funktion fehlt
; Ausgabe:  CF=1 if BIOS doesn't support call
    STC                 ; SET CARRY FLAG

    JMP    END_WITH_CARRY_FLAG



; ****************************************
; INT15 Funktion 41H: Wait on External Event
; AH = 41h
; AL = condition type (see #00463)
; BH = condition compare or mask value
; BL = timeout value times 55 milliseconds
; 00h means no timeout
; DX = I/O port address if AL bit 4 set
; ES:DI -> user byte if AL bit 4 clear

; Ausgabe:  CF=1 if BIOS doesn't support call
; ****************************************
INT15_AH_41:

%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,15H
    CALL   DEBUG_TRACE_ENTRY
    POP    BP
    POP    AX
%endif


    MOV    AH,86H       ; Funktion fehlt
    MOV    AL,00H       ; Funktion fehlt
; Ausgabe:  CF=1 if BIOS doesn't support call
    STC                 ; SET CARRY FLAG

    JMP    END_WITH_CARRY_FLAG




; ****************************************
; INT15 Funktion 88H: Extended Memory Size
; Groesse des Extended Memory ermitteln
; Eingabe:  AH=88h
; Ausgabe:  Ausgabe: AX=Groesse des HI-Speichers oberhalb 1MB
;                    (Angabe in KB)
;                    CF=0 
;
; Das 8088-System hat keinen Extended Memory über 1MB.
; `AX=0` mit `CLC` ist die technisch korrektere Antwort ("0 KB extended memory vorhanden"). 
; ****************************************
INT15_AH_88:

%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,15H
    CALL   DEBUG_TRACE_ENTRY
    POP    BP
    POP    AX
%endif


    MOV    AX,0000H     ; Funktion fehlt

%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,15H
    CALL   DEBUG_TRACE_RETURN
    POP    BP
    POP    AX
%endif

    CLC                 ; CLEAR CARRY FLAG SUCCESFUL


    JMP    END_WITH_CARRY_FLAG






; ****************************************
; INT15 Funktion C0H: Get System Configuration
; Ausgabe:  CF=1 if BIOS doesn't support call
; ****************************************
INT15_AH_C0:

%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,15H
    CALL   DEBUG_TRACE_ENTRY
    POP    BP
    POP    AX
%endif



    MOV     AX,BIOS_Segment
    MOV     ES,AX

    MOV     BX, SYS_CONF_PARAM



    MOV    AH,00H       ; o.k.
;    MOV    AH,86H       ; Funktion fehlt


%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,15H
    CALL   DEBUG_TRACE_RETURN
    POP    BP
    POP    AX
%endif


; Ausgabe:  CF=1 if BIOS doesn't support call
;    STC                 ; SET CARRY FLAG



;    MOV     AH,00H
    CLC                 ; CLEAR CARRY FLAG SUCCESFUL


    JMP    END_WITH_CARRY_FLAG




SYS_CONF_PARAM:
    DW   08H    ;  00   word   length of descriptor (8 minimum)
    DB   0FFH   ;  02   byte   model byte (same as F000:FFFE, not reliable)
    DB   00H    ;  03   byte   secondary model byte
    DB   00H    ;  04   byte   BIOS revision level (zero based)
    DB   00H    ;  05   byte   feature information, see below
    DB   00H    ;  06
    DB   00H    ;  07
    DB   00H    ;  08
    DB   00H    ;  09

    DB 00, 00, 00, 00, 00, 00, 00, 00
    DB 00, 00, 00, 00, 00, 00, 00, 00
    DB 00, 00, 00, 00, 00, 00, 00, 00
    DB 00, 00, 00, 00, 00, 00, 00, 00

SYS_CONF_PARAM_END:





; **************************
; * INT 16
; **************************

%include "INT16.ASM"

; --------------------------



; *****************************************
; ***   INT 17 -  Druckerschnittstelle  ***
; *****************************************
INT_17: ;Printer

    CMP AH,01H        ;Get System Configuration
    JZ INT17_AH_01

%if ERROR_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,17H
    CALL   DEBUG_TRACE_UNSUPPORTED
    POP    BP
    POP    AX
%endif


    IRET    ;RETURN FROM INTERRUPT



; ****************************************
; INT17 Funktion 01H: Printer Port initialisieren
;
; Eingabe:  AH=01H
;           DX=Schnittstelle
;
; Ausgabe:  AH=Statusbyte
; ****************************************
INT17_AH_01:

%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,17H
    CALL   DEBUG_TRACE_ENTRY
    POP    BP
    POP    AX
%endif

    MOV    AX,9000H       ; AH=Statusbyte


    IRET    ;RETURN FROM INTERRUPT




; ******************************
; ***   INT 18 -  ROM-Basic  ***
; ******************************

%include "INT18.ASM"

; --------------------------






; *******************************
; ***   INT 19 -  Bootstrap   ***
; *******************************

INT_19: ;Bootstrap
;	JMP 0XFFFF:0X0000			;JUMPS TO BOOT CODE
%if ERROR_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,19H
    CALL   DEBUG_TRACE_UNSUPPORTED
    POP    BP
    POP    AX
%endif

    IRET    ;RETURN FROM INTERRUPT



; *******************************
; ***   INT 1A -  Systemzeit  ***
; *******************************

%include "INT1A.ASM"

; --------------------------



INT_1B: ;Keyboard Break

%if ERROR_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,1BH
    CALL   DEBUG_TRACE_UNSUPPORTED
    POP    BP
    POP    AX
%endif

    IRET    ;RETURN FROM INTERRUPT




; Timerinterrupt (INT 1C)
; Bei jedem Überlauf des Timers 0 wird der INT 8 ausgelöst. Anschließend setzt die
; Software einen INT 1C (Timer-Folgeinterrupt). Dieser Vektor wird vom BIOS auf eine
; IRET-Anweisung initialisiert. Es besteht dann die Möglichkeit, den Vektor auf
; Anwenderprogramme umzulegen, die dann bei jedem Timertick aktiviert werden.

INT_1C: ;Timer Tick


    IRET    ;RETURN FROM INTERRUPT



;----------------------------------------------------------------------------;
; Video Parameters. Point to a table containing
; initialization and information for the Video Controller chip.
;=========================================================================
; int_1D - Video parameters tables
; Contains values loaded to MC6845 CRTC registers 00h to 0Fh during
; video mode initialization
;-------------------------------------------------------------------------
; int 1D (MDA and CGA Video Parm Table)
INT_1D:
; CGA test 40x25 modes
    db  38h, 28h, 2Dh, 0Ah, 1Fh, 06h, 19h, 1Ch
    db  02h, 07h, 06h, 07h, 00h, 00h, 00h, 00h

; CGA text 80x25 modes
    db  71h, 50h, 5Ah, 0Ah, 1Fh, 06h, 19h, 1Ch
    db  02h, 07h, 06h, 07h, 00h, 00h, 00h, 00h

; CGA graphics modes
    db  38h, 28h, 2Dh, 0Ah, 7Fh, 06h, 64h, 70h
    db  02h, 01h, 06h, 07h, 00h, 00h, 00h, 00h

; MDA text 80x25 mode
    db  61h, 50h, 52h, 0Fh, 19h, 06h, 19h, 19h
    db  02h, 0Dh, 0Bh, 0Ch, 00h, 00h, 00h, 00h

page_size:
    dw  0800h    ; text 40x25 mode
    dw  1000h    ; text 80x25 mode
    dw  4000h    ; graphics modes
    dw  4000h

columns:
    db  40, 40    ; modes 0, 1 - 40x25
    db  80, 80    ; modes 2, 3 - 80x25
    db  40, 40    ; modes 4, 5 - 40x25
    db  80, 80    ; modes 6, 7 - 80x25

MODES  db  2Ch,28h,2Dh,29h,2Ah,2Eh,1Eh,29h ; Table of mode sets

TABMUL  db  00h,00h,10h,10h,20h,20h,20h,30h ; Table lookup for multiply

;=========================================================================



INT_1E:
; Diskette Parameters. Point to a table containing
; initialization information for the diskette controller.

;********************************
;**  Diskette Parameter Table  **
;********************************

Diskette_Parameter_Table:
    DB  0DFH   ; Steppertime = D, HD Unload = F
    DB  002H   ; HD Load = 1, Mode = DMA
    DB  025H   ; Motor Wait
    DB  002H   ; n * 256 Byte pro Sektor
    DB  FD_SPT ; Last Sector per Track
    DB  01BH   ; GAP length ID-Data
    DB  0FFH   ; Disk Transfer length
    DB  054H   ; GAP length for Format
    DB  0F6H   ; Fill Byte for Format
    DB  00FH   ; Head settle Time (ms)
    DB  008H   ; Motor Start Time (1/8) Sek.
Diskette_Parameter_Table_END:


    DB 00, 00, 00, 00, 00, 00, 00, 00
    DB 00, 00, 00, 00, 00, 00, 00, 00
    DB 00, 00, 00, 00, 00, 00, 00, 00
    DB 00, 00, 00, 00, 00, 00, 00, 00




INT_1F: ;Video Graphics Characters
; Not to be called; simply a pointer to the VGCT (Video Graphics Character Table),
; which contains the data for ASCII characters 80h to FFh

; VGCT

    DB 78H, 0CCH, 0C0H, 0CCH, 78H, 18H, 0CH, 78H, 00H, 0CCH, 00H, 0CCH, 0CCH, 0CCH, 7EH, 00H
    DB 1CH, 00H, 78H, 0CCH, 0FCH, 0C0H, 78H, 00H, 7EH, 0C3H, 3CH, 06H, 3EH, 66H, 3FH, 00H
    DB 0CCH, 00H, 78H, 0CH, 7CH, 0CCH, 7EH, 00H, 0E0H, 00H, 78H, 0CH, 7CH, 0CCH, 7EH, 00H
    DB 30H, 30H, 78H, 0CH, 7CH, 0CCH, 7EH, 00H, 00H, 00H, 78H, 0C0H, 0C0H, 78H, 0CH, 38H
    DB 7EH, 0C3H, 3CH, 66H, 7EH, 60H, 3CH, 00H, 0CCH, 00H, 78H, 0CCH, 0FCH, 0C0H, 78H, 00H
    DB 0E0H, 00H, 78H, 0CCH, 0FCH, 0C0H, 78H, 00H, 0CCH, 00H, 70H, 30H, 30H, 30H, 78H, 00H
    DB 7CH, 0C6H, 38H, 18H, 18H, 18H, 3CH, 00H, 0E0H, 00H, 70H, 30H, 30H, 30H, 78H, 00H
    DB 0C6H, 38H, 6CH, 0C6H, 0FEH, 0C6H, 0C6H, 00H, 30H, 30H, 00H, 78H, 0CCH, 0FCH, 0CCH, 00H





; **************************
; * INT 33H
; **************************

%include "INT33.ASM"

; --------------------------






; **************************
; * VGA-BIOS
; **************************

%include "VGABIOS.ASM"

; --------------------------





; **************************
; * DEBUG
; **************************

%include "DEBUG.ASM"

; --------------------------



