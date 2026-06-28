
; *******************************
; ***   INT 1A -  Systemzeit  ***
; *******************************
;
; Systemzeit (INT 1A)
; Das BIOS führt die Systemzeit als 4-Byte-Variable im BIOS-Datenbereich. Sie wird aus
; dem Timer-Interrupt gewonnen. Mit dem INT 1A läßt sich der Wert dieser Zeitvariablen
; lesen und stellen. Hierzu gelten folgende Konventionen:






; ************************************
; *** Interrupt-Routine fuer INT1A ***
; ************************************
;
INT_1A: ; Systemzeit


    CMP    AH,00H
    JNE    INT_1A_01
    JMP    INT1A_AH_00


INT_1A_01:
    CMP    AH,01H
    JNE    INT_1A_02
    JMP    INT1A_AH_01


INT_1A_02:
    CMP    AH,02H
    JNE    INT_1A_03
    JMP    INT1A_AH_02


INT_1A_03:
    CMP    AH,03H
    JNE    INT_1A_04
    JMP    INT1A_AH_03


INT_1A_04:
    CMP    AH,04H
    JNE    INT_1A_NOT_FOUND
    JMP    INT1A_AH_04


INT_1A_NOT_FOUND:

%if ERROR_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,1AH
    CALL   DEBUG_TRACE_UNSUPPORTED
    POP    BP
    POP    AX
%endif

    IRET    ;RETURN FROM INTERRUPT






; ****************************************
; INT1A Funktion 00H: Zeit lesen (AH = 00H)
;
; Eingabe:  AH=00H (Get Time)
;
; Ausgabe:  CX= Zähler High Word
;           DX= Zähler Low Word
;           AL= Übertragsflag
; ****************************************
INT1A_AH_00:

%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,1AH
    CALL   DEBUG_TRACE_ENTRY
    POP    BP
    POP    AX
%endif

    PUSH   DS          ;STORE DS
    PUSH   BX          ;STORE BX
    MOV    BX,0040H    ;BIOS DATA AREA
    MOV    DS,BX       ;SET DATA SEGMENT

    MOV    BX,006CH    ;OFFSET 6CH = Zähler Low Word
    MOV    DX,[ds:BX]  ;STORE Zähler Low Word

    MOV    BX,006EH    ;OFFSET 6CH = Zähler High Word
    MOV    CX,[ds:BX]  ;STORE Zähler Low Word

    POP    BX          ;RESTORE BX
    POP    DS          ;RESTORE DS

    MOV    AL,00H          ; 

%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,1AH
    CALL   DEBUG_TRACE_RETURN
    POP    BP
    POP    AX
%endif


    IRET    ;RETURN FROM INTERRUPT




; ****************************************
; INT1A Funktion 01H: Zeit setzen (AH = 01H)
; ****************************************
; Eingabe:  01H (Set Time)
;           CX= Zähler High Word
;           DX= Zähler Low Word
;
; Ausgabe:  keine
; ****************************************
INT1A_AH_01:

%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,1AH
    CALL   DEBUG_TRACE_ENTRY
    POP    BP
    POP    AX
%endif

    PUSH   DS          ;STORE DS
    PUSH   BX          ;STORE BX
    MOV    BX,0040H    ;BIOS DATA AREA
    MOV    DS,BX       ;SET DATA SEGMENT

    MOV    BX,006CH    ;OFFSET 6CH = Zähler Low Word
    MOV    [ds:BX],DX  ;STORE Zähler Low Word

    MOV    BX,006EH    ;OFFSET 6EH = Zähler High Word
    MOV    [ds:BX],CX  ;STORE Zähler Low Word

    POP    BX          ;RESTORE BX
    POP    DS          ;RESTORE DS

%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,1AH
    CALL   DEBUG_TRACE_RETURN
    POP    BP
    POP    AX
%endif


    IRET    ;RETURN FROM INTERRUPT




; ****************************************
; INT1A Funktion 02H: Read Real Time Clock (AH = 02H)
;
; Eingabe:  AH=02H (Read RTC Time)
;
; Ausgabe:  CY=1 -> keine RTC
;           CY=0 -> RTC gefunden
;           CH= Stunden im BCD-Format
;           CL= Minuten im BCD-Format
;           DH= Sekunden im BCD-Format
;           DL: 1 = 24 Std. 0 = 12 Std.
; ****************************************
INT1A_AH_02:

%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,1AH
    CALL   DEBUG_TRACE_ENTRY
    POP    BP
    POP    AX
%endif


    PUSH   BX

    ; CH= Stunden im BCD-Format
    MOV    BX, TIM_STUNDE
    MOV    CH, [cs:BX]

    ; CL= Minuten im BCD-Format
    MOV    BX, TIM_MINUTE
    MOV    CL, [cs:BX]

    ; DH= Sekunden im BCD-Format
    MOV    BX, TIM_SEKUNDE
    MOV    DH, [cs:BX]

    MOV    DL, 01

    POP    BX


%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,1AH
    CALL   DEBUG_TRACE_RETURN
    POP    BP
    POP    AX
%endif

    CLC                 ; CY=0 -> RTC gefunden
;    STC                 ; CY=1 -> keine RTC


    JMP    END_WITH_CARRY_FLAG







; ****************************************
; INT1A Funktion 03H: Set Real Time Clock (AH = 03H)
; ****************************************
;
; Eingabe:  AH=03H (Set RTC Time)
;           CH= Stunden im BCD-Format
;           CL= Minuten im BCD-Format
;           DH= Sekunden im BCD-Format
;           DL: 1 = 24 Std. 0 = 12 Std.
;
; Ausgabe:  keine
; ****************************************
INT1A_AH_03:

%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,1AH
    CALL   DEBUG_TRACE_ENTRY
    POP    BP
    POP    AX
%endif


    PUSH   BX

    ; CH= Stunden im BCD-Format
    MOV    BX, TIM_STUNDE
    MOV    [cs:BX],CH

    ; CL= Minuten im BCD-Format
    MOV    BX, TIM_MINUTE
    MOV    [cs:BX],CL

    ; DH= Sekunden im BCD-Format
    MOV    BX, TIM_SEKUNDE
    MOV    [cs:BX],DH


    POP    BX


%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,1AH
    CALL   DEBUG_TRACE_RETURN
    POP    BP
    POP    AX
%endif

    CLC                 ; CY=0 -> RTC gefunden
;    STC                 ; CY=1 -> keine RTC


    JMP    END_WITH_CARRY_FLAG





; ****************************************
; INT1A Funktion 04H: Read Date from RTC
;
; Eingabe:  AH=04H (Read RTC Date)
;
; Ausgabe:  CY=1 -> keine RTC
;           CY=0 -> RTC gefunden
;           CH= Jahrhundert im BCD-Format
;           CL= Jahr im BCD-Format
;           DH= Monat im BCD-Format
;           DL= Tag im BCD-Format
; ****************************************
INT1A_AH_04:

%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,1AH
    CALL   DEBUG_TRACE_ENTRY
    POP    BP
    POP    AX
%endif


    PUSH   BX

    ; CH= Jahrhundert im BCD-Format
    MOV    BX, DAT_JAHRHUN
    MOV    CH, [cs:BX]

    ; CL= Jahr im BCD-Format
    MOV    BX, DAT_JAHR
    MOV    CL, [cs:BX]

    ; DH= Monat im BCD-Format
    MOV    BX, DAT_MONAT
    MOV    DH, [cs:BX]

    ; DL= Tag im BCD-Format
    MOV    BX, DAT_TAG
    MOV    DL, [cs:BX]

    POP    BX


%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,1AH
    CALL   DEBUG_TRACE_RETURN
    POP    BP
    POP    AX
%endif


    CLC                 ; CY=0 -> RTC gefunden
;    STC                 ; CY=1 -> keine RTC



    JMP    END_WITH_CARRY_FLAG







; **********************************************
; --------------------------------------------------



; ********************************
; *** Variablen fuer die RTC   ***
; ********************************
;
DAT_TAG     DB    00    ; 0 - Datum Tag
DAT_MONAT   DB    00    ; 1 - Datum Monat
DAT_JAHRHUN DB    00    ; 2 - Datum Jahrhundert
DAT_JAHR    DB    00    ; 3 - Datum Jahr
TIM_STUNDE  DB    00    ; 4 - Zeit Stunde
TIM_MINUTE  DB    00    ; 5 - Zeit Minute
TIM_SEKUNDE DB    00    ; 6 - Zeit Sekunde








; ******************************************
;   Routine fuer das Einlesen der Datums- 
;   und Zeitdaten
; ******************************************
;
READ_DATE_TIME_DEVICE: 

    PUSH   AX
    PUSH   BX


    MOV    AL,IORQ_TIME
    OUT    AUSGANG,AL


    ; 0. Einlesen Datum Tag - 1Byte
    ; DAT_TAG     DB    00    ; 0 - Datum Tag
    MOV    BX, DAT_TAG
    IN     AL,AUSGANG
    MOV    [cs:BX], AL


    ; 1. Einlesen Datum Monat - 1Byte
    ; DAT_MONAT   DB    00    ; 1 - Datum Monat
    MOV    BX, DAT_MONAT
    IN     AL,AUSGANG
    MOV    [cs:BX], AL


    ; 2. Einlesen Datum Jahrhundert - 1Byte
    ; DAT_JAHRHUN DB    00    ; 2 - Datum Jahrhundert
    MOV    BX, DAT_JAHRHUN
    IN     AL,AUSGANG
    MOV    [cs:BX], AL


    ; 3. Einlesen Datum Jahr - 1Byte
    ; DAT_JAHR    DB    00    ; 3 - Datum Jahr
    MOV    BX, DAT_JAHR
    IN     AL,AUSGANG
    MOV    [cs:BX], AL


    ; 4. Einlesen Zeit Stunde - 1Byte
    ; TIM_STUNDE  DB    00    ; 4 - Zeit Stunde
    MOV    BX, TIM_STUNDE
    IN     AL,AUSGANG
    MOV    [cs:BX], AL


    ; 5. Einlesen Zeit Minute - 1Byte
    ; TIM_MINUTE  DB    00    ; 5 - Zeit Minute
    MOV    BX, TIM_MINUTE
    IN     AL,AUSGANG
    MOV    [cs:BX], AL


    ; 6. Einlesen Zeit Sekunde - 1Byte
    ; TIM_SEKUNDE DB    00    ; 6 - Zeit Sekunde
    MOV    BX, TIM_SEKUNDE
    IN     AL,AUSGANG
    MOV    [cs:BX], AL




    POP    BX
    POP    AX



    RET    ;RETURN FROM INTERRUPT
