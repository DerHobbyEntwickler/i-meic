; ============================================================================
;  VGA-BIOS Treiber  -  NASM
; ============================================================================


; ----------------------------------------------------------------------------
;  Vereinbarungsteil i-meic Hardware
; ----------------------------------------------------------------------------

IO_PORT              EQU   0            ; IO-Port fuer die Ausgabe



; ----------------------------------------------------------------------------
;  Vereinbarungsteil VIDEO INT 10H
; ----------------------------------------------------------------------------
; 01..99 -> SEND 2 PARAM
VID_SET_CURSOR_POS   EQU   1            ; VIDEO_SET_CURSOR_POS
VID_SET_VIDEO_MODE   EQU   2            ; VIDEO_Set_Video_Mode
VID_SCROLL_PARAM_01  EQU   3            ; VIDEO_PAR_Scroll_01
VID_SCROLL_PARAM_02  EQU   4            ; VIDEO_PAR_Scroll_02
VID_SCROLL_UP        EQU   5            ; VIDEO_PAR_Scroll_Up
VID_CONOUT           EQU   6            ; VIDEO_CONOUT
VID_SCROLL_DOWN      EQU   8            ; VIDEO_PAR_Scroll_Down
VID_CONOUT_09H_P1    EQU   10           ; VIDEO_CONOUT_09H_01
VID_CONOUT_09H_P2    EQU   11           ; VIDEO_CONOUT_09H_02
VID_CONOUT_0AH_P1    EQU   12           ; VIDEO_CONOUT_0AH_01
VID_CONOUT_0AH_P2    EQU   14           ; VIDEO_CONOUT_0AH_02
; 101..199 -> RECEIVE 2 PARAM
VID_GET_CURSOR_POS   EQU   101          ; VIDEO_GET_CURSOR_POS
VID_GET_CHAR_ATTR    EQU   102          ; VIDEO_GET_ChrAtt_CurPos


; ----------------------------------------------------------------------------
;  Offset der Register auf dem Stack
; ----------------------------------------------------------------------------
ST_REG_AX            EQU   0
ST_REG_AL            EQU   ST_REG_AX
ST_REG_AH            EQU   ST_REG_AX+1
ST_REG_BX            EQU   ST_REG_AX+2
ST_REG_BL            EQU   ST_REG_BX
ST_REG_BH            EQU   ST_REG_BX+1
ST_REG_CX            EQU   ST_REG_BX+2
ST_REG_CL            EQU   ST_REG_CX
ST_REG_CH            EQU   ST_REG_CX+1
ST_REG_DX            EQU   ST_REG_CX+2
ST_REG_DL            EQU   ST_REG_DX
ST_REG_DH            EQU   ST_REG_DX+1
ST_REG_DI            EQU   ST_REG_DX+2
ST_REG_SI            EQU   ST_REG_DI+2
ST_REG_DS            EQU   ST_REG_SI+2
ST_REG_ES            EQU   ST_REG_DS+2
ST_REG_BP            EQU   ST_REG_ES+2


; ----------------------------------------------------------------------------
;  Pascal-Konstanten (aus A3MOD.SRC)
; ----------------------------------------------------------------------------
MAX_ROW              EQU   24           ; -> 25 Zeilen (0..24)
MAX_COL              EQU   79           ; -> 80 Spalten (0..79)
FILL_CHAR            EQU   20H          ; ' '
FILL_ATTR            EQU   07H          ; HG Schwarz, VG Hellgrau

;  SCREEN-Layout (B800:0000):
;  Zeichen steht auf +0, Attribut auf +1
;  Fuellwort (Zeichen=20, Attr=07) 

SCREEN_SEG           EQU   0B800H
ROW_BYTES            EQU   160          ; 80 Spalten * 2 Byte
; Cursor im BDA:
BDA_SEG              EQU   0040H
BDA_CUR_COL_OFF      EQU   0050H
BDA_CUR_ROW_OFF      EQU   0051H


; ============================================================================
;  CODE
; ============================================================================

; ----------------------------------------------------------------------------
;  BIOS_ENTRY - Einsprungadresse auf E000:0000
; ----------------------------------------------------------------------------
BIOS_ENTRY:

; ----------------------------------------------------------------------------
;  INT10_DISPATCH - Sprungverteiler Video-BIOS
; ----------------------------------------------------------------------------
INT10_DISPATCH:

; --- Debug-Trace beim Eintritt ---
    PUSH  AX
    PUSH  BP
    MOV   BP,AX
    MOV   AH,10H
    CALL  DEBUG_TRACE_ENTRY
    POP   BP
    POP   AX

; --- Registerblock sichern (Reihenfolge fix!) ---
    PUSH  BP
    PUSH  ES
    PUSH  DS
    PUSH  SI
    PUSH  DI
    PUSH  DX
    PUSH  CX
    PUSH  BX
    PUSH  AX

; --- DS = CS = E000 ---
    PUSH  CS
    POP   DS

; --- Dispatch nach AH ---
    CMP   AH,00H
    JNE   TRY_AH_01
    JMP   FN00_SET_VIDEO_MODE

TRY_AH_01:
    CMP   AH,01H
    JNE   TRY_AH_02
    JMP   FN01_SET_CURSOR_SHAPE

TRY_AH_02:
    CMP   AH,02H
    JNE   TRY_AH_03
    JMP   FN02_SET_CURSOR_POS

TRY_AH_03:
    CMP   AH,03H
    JNE   TRY_AH_06
    JMP   FN03_GET_CURSOR_POS

TRY_AH_06:
    CMP   AH,06H
    JNE   TRY_AH_07
    JMP   FN06_SCROLL_UP

TRY_AH_07:
    CMP   AH,07H
    JNE   TRY_AH_08
    JMP   FN07_SCROLL_DOWN

TRY_AH_08:
    CMP   AH,08H
    JNE   TRY_AH_09
    JMP   FN08_READ_CHAR_ATTR

TRY_AH_09:
    CMP   AH,09H
    JNE   TRY_AH_0A
    JMP   FN09_WRITE_CHAR_ATTR

TRY_AH_0A:
    CMP   AH,0AH
    JNE   TRY_AH_0E
    JMP   FN0A_WRITE_CHAR

TRY_AH_0E:
    CMP   AH,0EH
    JNE   TRY_AH_0F
    JMP   FN0E_TELETYPE

TRY_AH_0F:
    CMP   AH,0FH
    JNE   TRY_AH_11
    JMP   FN0F_GET_VIDEO_STATE

TRY_AH_11:
    CMP   AH,11H
    JNE   TRY_AH_12
    JMP   FN11_GET_FONT_INFO

TRY_AH_12:
    CMP   AH,12H
    JNE   INT10_UNSUPPORTED
    JMP   FN12_VIDEO_CONFIG


; --- Interrupt-Funktion nicht gefunden ---
INT10_UNSUPPORTED:
    POP   AX
    POP   BX
    POP   CX
    POP   DX
    POP   DI
    POP   SI
    POP   DS
    POP   ES
    POP   BP

    PUSH  AX
    PUSH  BP
    MOV   BP,AX
    MOV   AH,10H
    CALL  DEBUG_TRACE_UNSUPPORTED
    POP   BP
    POP   AX

    IRET


; --- normaler Ruecksprung ---
INT10_RETURN:
    POP   AX
    POP   BX
    POP   CX
    POP   DX
    POP   DI
    POP   SI
    POP   DS
    POP   ES
    POP   BP

    PUSH  AX
    PUSH  BP
    MOV   BP,AX
    MOV   AH,10H
    CALL  DEBUG_TRACE_RETURN
    POP   BP
    POP   AX

    IRET


; ============================================================================
;  INT-10h-Handler
; ============================================================================

; ----------------------------------------------------------------------------
;  Bildschirmmodus waehlen (AH = 00H)
; ----------------------------------------------------------------------------
FN00_SET_VIDEO_MODE:
    MOV   BL, AL
    MOV   AL, VID_SET_VIDEO_MODE
    CALL  VIDEO_SEND_2PARAM
    CALL  PROC_SET_MODE
    JMP   INT10_RETURN


; ----------------------------------------------------------------------------
;  Cursor-Groesse definieren (AH = 01H)  -> wird ignoriert
; ----------------------------------------------------------------------------
FN01_SET_CURSOR_SHAPE:
    JMP   INT10_RETURN


; ----------------------------------------------------------------------------
;  Cursor positionieren (AH = 02H)
; ----------------------------------------------------------------------------
FN02_SET_CURSOR_POS:

    MOV   AL, VID_SET_CURSOR_POS
    MOV   BL, DL                        ; Spaltennummer als 1.Parameter
    MOV   BH, DH                        ; Zeilennummer als 2.Parameter
    CALL  VIDEO_SEND_2PARAM

    ; Setzen von Spalte/Zeile im BDA
    MOV   BX,BDA_SEG
    MOV   ES,BX
    MOV   BX,BDA_CUR_COL_OFF
    MOV   [ES:BX], DL                   ; DL = Spalte
    MOV   BX,BDA_CUR_ROW_OFF
    MOV   [ES:BX], DH                   ; DH = Zeile

    JMP   INT10_RETURN


; ----------------------------------------------------------------------------
;  Cursorposition ermitteln (AH = 03H)
; ----------------------------------------------------------------------------
FN03_GET_CURSOR_POS:

    ; Lesen von Spalte/Zeile aus dem BDA
    MOV   BX,BDA_SEG
    MOV   ES,BX
    MOV   BX,BDA_CUR_COL_OFF
    MOV   DL, [ES:BX]                   ; DL = Spalte
    MOV   BX,BDA_CUR_ROW_OFF
    MOV   DH, [ES:BX]                   ; DH = Zeile

    ; Rueckgabe in den Stackrahmen
    PUSH  SS
    POP   ES
    MOV   BP,SP
    MOV   [ES:BP+ST_REG_DX],DX
    MOV   CX,0607H
    MOV   [ES:BP+ST_REG_CX],CX

    JMP   INT10_RETURN


; ----------------------------------------------------------------------------
;  Bildschirmfenster Scroll Up (AH = 06H)
; ----------------------------------------------------------------------------
FN06_SCROLL_UP:
    PUSH  AX
    PUSH  BX

    ; 1.Durchgang: P1=Anzahl Zeilen, P2=Attribut Leerzeile (BH)
    MOV   BL,AL
    MOV   AL,VID_SCROLL_PARAM_01
    CALL  VIDEO_SEND_2PARAM

    ; 2.Durchgang: P1=Eckspalte oben links, P2=Eckzeile oben links
    MOV   BL,CL
    MOV   BH,CH
    MOV   AL,VID_SCROLL_PARAM_02
    CALL  VIDEO_SEND_2PARAM

    ; 3.Durchgang: P1=Eckspalte unten rechts, P2=Eckzeile unten rechts
    MOV   BL,DL
    MOV   BH,DH
    MOV   AL,VID_SCROLL_UP
    CALL  VIDEO_SEND_2PARAM

    POP   BX
    POP   AX

    MOV   [COUNT_LO], AL
    MOV   [OUT_ATTR], BH
    MOV   [WIN_TOP_ROW], CH
    MOV   [WIN_LEFT_COL], CL
    MOV   [WIN_BOT_ROW], DH
    MOV   [WIN_RIGHT_COL], DL
    CALL  PROC_SCROLL_UP

    JMP   INT10_RETURN


; ----------------------------------------------------------------------------
;  Bildschirmfenster Scroll Down (AH = 07H)
; ----------------------------------------------------------------------------
FN07_SCROLL_DOWN:
    PUSH  AX
    PUSH  BX

    MOV   BL,AL
    MOV   AL,VID_SCROLL_PARAM_01
    CALL  VIDEO_SEND_2PARAM
    MOV   BL,CL
    MOV   BH,CH
    MOV   AL,VID_SCROLL_PARAM_02
    CALL  VIDEO_SEND_2PARAM
    MOV   BL,DL
    MOV   BH,DH
    MOV   AL,VID_SCROLL_DOWN
    CALL  VIDEO_SEND_2PARAM

    POP   BX
    POP   AX

    MOV   [COUNT_LO], AL
    MOV   [OUT_ATTR], BH
    MOV   [WIN_TOP_ROW], CH
    MOV   [WIN_LEFT_COL], CL
    MOV   [WIN_BOT_ROW], DH
    MOV   [WIN_RIGHT_COL], DL
    CALL  PROC_SCROLL_DOWN

    JMP   INT10_RETURN


; ----------------------------------------------------------------------------
;  Zeichen und Attribut an Cursorposition lesen (AH = 08H)
; ----------------------------------------------------------------------------
FN08_READ_CHAR_ATTR:

    CALL  PROC_READ_CHAR_ATTR

    PUSH  CS
    POP   DS
    PUSH  SS
    POP   ES
    MOV   BP,SP

    MOV   AL,[OUT_CHAR]
    MOV   [ES:BP+ST_REG_AL],AL
    MOV   AH,[OUT_ATTR]
    MOV   [ES:BP+ST_REG_AH],AH

    JMP   INT10_RETURN


; ----------------------------------------------------------------------------
;  Zeichen und Attribut an Cursorposition schreiben (AH = 09H)
; ----------------------------------------------------------------------------
FN09_WRITE_CHAR_ATTR:

    PUSH  AX
    PUSH  BX

    ; Teil 1 - TELETYPE
    MOV   BH,BL                         ; P2 <- Attributbyte
    MOV   BL,AL                         ; P1 <- Zeichencode
    MOV   AL,VID_CONOUT_09H_P1
    CALL  VIDEO_SEND_2PARAM

    MOV   BH,CH                         ; P2 <- Kopien HI
    MOV   BL,CL                         ; P1 <- Kopien LO
    MOV   AL,VID_CONOUT_09H_P2
    CALL  VIDEO_SEND_2PARAM

    POP   BX
    POP   AX

    ; Teil 2 - BWS
    MOV   [OUT_CHAR], AL
    MOV   [OUT_ATTR], BL
    MOV   [COUNT_LO], CL
    MOV   [COUNT_HI], CH
    CALL  PROC_WRITE_CHAR_ATTR_REP

    JMP   INT10_RETURN


; ----------------------------------------------------------------------------
;  Zeichen an Cursorposition schreiben (AH = 0AH)
; ----------------------------------------------------------------------------
FN0A_WRITE_CHAR:
    PUSH  AX
    PUSH  BX

    ; Teil 1 - TELETYPE
    MOV   BL,AL                         ; P1 <- Zeichencode
    MOV   AL,VID_CONOUT_0AH_P1
    CALL  VIDEO_SEND_2PARAM

    MOV   BH,CH                         ; P2 <- Kopien HI
    MOV   BL,CL                         ; P1 <- Kopien LO
    MOV   AL,VID_CONOUT_0AH_P2
    CALL  VIDEO_SEND_2PARAM

    POP   BX
    POP   AX

    ; Teil 2 - BWS
    MOV   [OUT_CHAR], AL
    MOV   [COUNT_LO], CL
    MOV   [COUNT_HI], CH
    CALL  PROC_WRITE_CHAR_REP

    JMP   INT10_RETURN


; ----------------------------------------------------------------------------
;  Zeichen ausgeben - TELETYPE (AH = 0EH)
; ----------------------------------------------------------------------------
FN0E_TELETYPE:
    PUSH  AX

    ; Teil 1 - TELETYPE
    MOV   BL,AL
    MOV   AL,VID_CONOUT
    CALL  VIDEO_SEND_2PARAM

    POP   AX

    ; Teil 2 - BWS
    MOV   [OUT_CHAR], AL
    CALL  PROC_TELETYPE

    JMP   INT10_RETURN


; ----------------------------------------------------------------------------
;  Bildschirmstatus lesen (AH = 0FH)
; ----------------------------------------------------------------------------
FN0F_GET_VIDEO_STATE:

    MOV   AL,03                         ; Bildschirmmodus
    MOV   AH,80                         ; Bildschirmspalten
    MOV   BH,00                         ; aktuelle Bildschirmseite

    PUSH  SS
    POP   ES
    MOV   BP,SP
    MOV   [ES:BP+ST_REG_AL],AL
    MOV   [ES:BP+ST_REG_AH],AH
    MOV   [ES:BP+ST_REG_BH],BH

    JMP   INT10_RETURN


; ----------------------------------------------------------------------------
;  Funktion 11h: GET FONT INFORMATION
; ----------------------------------------------------------------------------
FN11_GET_FONT_INFO:

    CMP   AL,30H
    JZ    FN11_SUB30_FONT_PTR
    JMP   INT10_UNSUPPORTED

FN11_SUB30_FONT_PTR:
    ; INT-Vektor von INT1F nach CX/DX laden
    MOV   AX,0000H
    MOV   ES,AX
    MOV   BX,1FH*4
    MOV   CX, [ES:BX]                   ; CX = Offset von INT1F
    ADD   BX,2
    MOV   DX, [ES:BX]                   ; DX = Segment von INT1F

    PUSH  SS
    POP   ES
    MOV   BP,SP
    MOV   [ES:BP+ST_REG_BP],CX          ; -> Rueckgabe BP
    MOV   [ES:BP+ST_REG_ES],DX          ; -> Rueckgabe ES

    MOV   CX,0010H
    MOV   DL,18H
    MOV   [ES:BP+ST_REG_CX],CX
    MOV   [ES:BP+ST_REG_DL],DL

    JMP   INT10_RETURN


; ----------------------------------------------------------------------------
;  Funktion 12h: Videokonfiguration
; ----------------------------------------------------------------------------
FN12_VIDEO_CONFIG:

    CMP   BL,10H
    JZ    FN12_SUB10_INFO
    CMP   BL,20H
    JZ    FN12_SUB20_TOGGLE
    CMP   BL,30H
    JZ    FN12_SUB30_SCANLINES
    JMP   INT10_UNSUPPORTED

; - AH=12H, BL=10H -
FN12_SUB10_INFO:
    MOV   BX,0003H
    MOV   CX,0009H
    PUSH  SS
    POP   ES
    MOV   BP,SP
    MOV   [ES:BP+ST_REG_BX],BX
    MOV   [ES:BP+ST_REG_CX],CX
    JMP   INT10_RETURN

; - AH=12H, BL=20H -
FN12_SUB20_TOGGLE:
    MOV   CX,00FFH
    PUSH  SS
    POP   ES
    MOV   BP,SP
    MOV   [ES:BP+ST_REG_CX],CX
    JMP   INT10_RETURN

; - AH=12H, BL=30H -
FN12_SUB30_SCANLINES:
    MOV   AX,1212H
    MOV   CX,00FFH
    PUSH  SS
    POP   ES
    MOV   BP,SP
    MOV   [ES:BP],AX                    ; ST_REG_AX = 0
    MOV   [ES:BP+ST_REG_CX],CX
    JMP   INT10_RETURN


; ============================================================================
;  i-meic Basisroutinen
; ============================================================================

; ******************************
;  VIDEO_SEND_2PARAM  - 2 Parameter senden
;  Eingabe: AL=Code, BL=P1, BH=P2
; ******************************
VIDEO_SEND_2PARAM:

    PUSH  AX
    MOV   AL,IORQ_VIDEO_SEND
    OUT   IO_PORT,AL

    POP   AX
    OUT   IO_PORT,AL                    ; Code der Routine

    MOV   AL,BL
    OUT   IO_PORT,AL                    ; 1.Parameter

    MOV   AL,BH
    OUT   IO_PORT,AL                    ; 2.Parameter

    RET


; ******************************
;  VIDEO_RECV_2PARAM  - 2 Parameter empfangen
;  Eingabe: AL=Code ; Ausgabe: BL=P1, BH=P2
; ******************************
VIDEO_RECV_2PARAM:

    PUSH  AX
    MOV   AL,IORQ_VIDEO_RESV
    OUT   IO_PORT,AL

    POP   AX
    OUT   IO_PORT,AL                    ; Code der Routine

    IN    AL,IO_PORT                    ; 1.Parameter -> BL
    MOV   BL,AL

    IN    AL,IO_PORT                    ; 2.Parameter -> BH
    MOV   BH,AL

    RET


; ============================================================================
;  Aus Pascal (A3MOD.SRC) konvertierte Routinen
; ============================================================================
;
;  Konventionen dieser Routinen:
;   - DS = E000 bleibt durchgehend erhalten (Zugriff auf OUT_CHAR..COUNT_HI
;     sowie auf die statischen Locals am Dateiende per [DS:offset]).
;   - ES dient als Arbeitssegment (B800 fuer SCREEN, 0040 fuer Cursor).
;   - Register duerfen frei veraendert werden (die Handler stellen den
;     Aufruferzustand ueber INT10_RETURN wieder her).
;   - Pascal-Locals liegen als statische Variablen im Speicher; da es keine
;     Rekursion/Reentrancy gibt, ist das funktionsidentisch.
; ============================================================================


; ----------------------------------------------------------------------------
;  Hilfsroutine SCREEN_PTR  (NICHT im Original - Adressberechnung)
;  Eingabe : AL = Zeile, BL = Spalte
;  Ausgabe : ES = B800, DI = (Zeile*80 + Spalte) * 2
;  Erhaelt : BX, CX, DX (DS unveraendert) ; veraendert: AX, DI, ES, Flags
; ----------------------------------------------------------------------------
SCREEN_PTR:

    PUSH  CX
    PUSH  BX
    MOV   CL,80
    MUL   CL                            ; AX = Zeile*80
    XOR   BH,BH
    ADD   AX,BX                         ; + Spalte (BL)
    ADD   AX,AX                         ; *2  (8086: kein SHL imm>1)
    MOV   DI,AX
    MOV   AX,SCREEN_SEG
    MOV   ES,AX
    POP   BX
    POP   CX

    RET


; ----------------------------------------------------------------------------
;  Hilfsroutine WRITE_CUR_CHAR_ATTR (Zeichen+Attribut an Cursorposition)
;  Schreibt OUT_ATTR -> [+0], OUT_CHAR -> [+1]
; ----------------------------------------------------------------------------
WRITE_CUR_CHAR_ATTR:

    MOV   AX,BDA_SEG
    MOV   ES,AX
    MOV   AL,[ES:BDA_CUR_ROW_OFF]
    MOV   BL,[ES:BDA_CUR_COL_OFF]
    CALL  SCREEN_PTR
	
    MOV   AL,[OUT_ATTR]
    MOV   [ES:DI+1],AL                    ; +0 Attribut
    MOV   AL,[OUT_CHAR]
    MOV   [ES:DI],AL                  ; +1 Zeichen

    RET


; ----------------------------------------------------------------------------
;  Hilfsroutine WRITE_CUR_CHAR (nur Zeichen an Cursorposition)
; ----------------------------------------------------------------------------
WRITE_CUR_CHAR:

    MOV   AX,BDA_SEG
    MOV   ES,AX
    MOV   AL,[ES:BDA_CUR_ROW_OFF]
    MOV   BL,[ES:BDA_CUR_COL_OFF]
    CALL  SCREEN_PTR
    MOV   AL,[OUT_CHAR]
    MOV   [ES:DI],AL                  ; +1 Zeichen

    RET


; ----------------------------------------------------------------------------
;  PROCEDURE SCREEN_CLEAR
; ----------------------------------------------------------------------------
SCREEN_CLEAR:

    MOV   byte [OUT_CHAR],FILL_CHAR
    MOV   byte [OUT_ATTR],FILL_ATTR

    ; gesamten Bildschirm mit Fuellwort (2007h) fuellen: 25*80 = 2000 Worte
    CLD
    MOV   AX,SCREEN_SEG
    MOV   ES,AX
    XOR   DI,DI


    MOV   AL,FILL_CHAR
    MOV   AH,FILL_ATTR


    MOV   CX,2000
    REP   STOSW

    ; Cursor 0,0
    MOV   AX,BDA_SEG
    MOV   ES,AX
    XOR   AL,AL
    MOV   [ES:BDA_CUR_COL_OFF],AL
    MOV   [ES:BDA_CUR_ROW_OFF],AL

    RET


; ----------------------------------------------------------------------------
;  PROCEDURE SCREEN_SCROLL_UP
; ----------------------------------------------------------------------------
SCREEN_SCROLL_UP:

    CLD
    ; Zeilen 1..24 nach 0..23 kopieren (24*80 = 1920 Worte)
    PUSH  DS
    MOV   AX,SCREEN_SEG
    MOV   DS,AX
    MOV   ES,AX
    MOV   SI,ROW_BYTES                  ; Zeile 1
    XOR   DI,DI                         ; Zeile 0
    MOV   CX,1920
    REP   MOVSW
    POP   DS                            ; DS = E000 wiederherstellen

    ; letzte Zeile (24) mit Fuellwort fuellen
    MOV   AX,SCREEN_SEG
    MOV   ES,AX
    MOV   DI,MAX_ROW*ROW_BYTES          ; 24*160 = 3840


    MOV   AL,FILL_CHAR
    MOV   AH,FILL_ATTR

 ;   MOV   AX,(FILL_CHAR<<8) | FILL_ATTR


    MOV   CX,80
    REP   STOSW

    ; Cursor: Spalte 0, Zeile 24
    MOV   AX,BDA_SEG
    MOV   ES,AX
    XOR   AL,AL
    MOV   [ES:BDA_CUR_COL_OFF],AL
    MOV   AL,MAX_ROW
    MOV   [ES:BDA_CUR_ROW_OFF],AL
    RET


; ----------------------------------------------------------------------------
;  Cursor-Routinen
;  (veraendern AX/ES/Flags frei; DS = E000 bleibt erhalten)
; ----------------------------------------------------------------------------
CUR_LEFT:
    MOV   AX,BDA_SEG
    MOV   ES,AX
    MOV   AL,[ES:BDA_CUR_COL_OFF]
    CMP   AL,1
    JBE   .done                         ; nur wenn Spalte > 1
    DEC   AL
    MOV   [ES:BDA_CUR_COL_OFF],AL
.done:
    RET

CUR_UP:
    MOV   AX,BDA_SEG
    MOV   ES,AX
    MOV   AL,[ES:BDA_CUR_ROW_OFF]
    CMP   AL,1
    JBE   .done                         ; nur wenn Zeile > 1
    DEC   AL
    MOV   [ES:BDA_CUR_ROW_OFF],AL
.done:
    RET

CUR_DOWN:
    MOV   AX,BDA_SEG
    MOV   ES,AX
    MOV   AL,[ES:BDA_CUR_ROW_OFF]
    INC   AL
    MOV   [ES:BDA_CUR_ROW_OFF],AL
    CMP   AL,MAX_ROW
    JBE   .done                         ; nur wenn Zeile > max_Zeilen scrollen
    CALL  SCREEN_SCROLL_UP
.done:
    RET

CUR_RIGHT:
    MOV   AX,BDA_SEG
    MOV   ES,AX
    MOV   AL,[ES:BDA_CUR_COL_OFF]
    INC   AL
    MOV   [ES:BDA_CUR_COL_OFF],AL
    CMP   AL,MAX_COL
    JBE   .done                         ; nur wenn Spalte > max_Spalten
    XOR   AL,AL
    MOV   [ES:BDA_CUR_COL_OFF],AL       ; Spalte := 0
    CALL  CUR_DOWN
.done:
    RET

CUR_HOME:
    MOV   AX,BDA_SEG
    MOV   ES,AX
    XOR   AL,AL
    MOV   [ES:BDA_CUR_COL_OFF],AL
    MOV   [ES:BDA_CUR_ROW_OFF],AL
    RET


; ----------------------------------------------------------------------------
;  PROCEDURE PROC_SET_MODE  (AH=00H)
; ----------------------------------------------------------------------------
PROC_SET_MODE:
    CALL  SCREEN_CLEAR
    RET


; ----------------------------------------------------------------------------
;  PROCEDURE PROC_SCROLL_UP  (Scroll Up, AH=06H)
; ----------------------------------------------------------------------------
PROC_SCROLL_UP:

    MOV   AL,FILL_CHAR
    MOV   AH,[OUT_ATTR]

    MOV   [F06_FILL_WORD],AX

    ; Anz_Fenst_Zeilen = WIN_BOT_ROW - WIN_TOP_ROW + 1
    MOV   AL,[WIN_BOT_ROW]
    SUB   AL,[WIN_TOP_ROW]
    INC   AL
    MOV   [F06_WIN_HEIGHT],AL

    ; IF COUNT_LO = 0 THEN nur loeschen
    MOV   AL,[COUNT_LO]
    OR    AL,AL
    JNZ   .scroll
    CALL  SCREEN_CLEAR
    RET

.scroll:
    ; FOR AdZ := 1 TO COUNT_LO
    MOV   byte [F06_SCROLL_IDX],1
.adz_loop:
    MOV   AL,[F06_SCROLL_IDX]
    CMP   AL,[COUNT_LO]
    JA    .done
    ; IF Anz_Fenst_Zeilen > 1
    MOV   AL,[F06_WIN_HEIGHT]
    CMP   AL,1
    JBE   .fill
    ; FOR AFZ := 1 TO Anz_Fenst_Zeilen
    MOV   byte [F06_WIN_ROW_IDX],1
.afz_loop:
    MOV   AL,[F06_WIN_ROW_IDX]
    CMP   AL,[F06_WIN_HEIGHT]
    JA    .fill
    ; z1 := WIN_TOP_ROW + AFZ - 1
    MOV   AL,[WIN_TOP_ROW]
    ADD   AL,[F06_WIN_ROW_IDX]
    DEC   AL
    MOV   [F06_ROW],AL
    ; FOR s1 := WIN_LEFT_COL TO WIN_RIGHT_COL : SCREEN[z1,s1] := SCREEN[z1+1,s1]
    MOV   AL,[WIN_LEFT_COL]
    MOV   [F06_COL],AL
.s_loop:
    MOV   AL,[F06_COL]
    CMP   AL,[WIN_RIGHT_COL]
    JA    .s_done
    MOV   AL,[F06_ROW]
    MOV   BL,[F06_COL]
    CALL  SCREEN_PTR                    ; ES=B800, DI=PTR(z1,s1)
    MOV   AX,[ES:DI+ROW_BYTES]          ; SCREEN[z1+1,s1]
    MOV   [ES:DI],AX
    INC   byte [F06_COL]
    JMP   .s_loop
.s_done:
    INC   byte [F06_WIN_ROW_IDX]
    JMP   .afz_loop

.fill:
    ; z1 := WIN_BOT_ROW ; FOR s1 := WIN_LEFT_COL TO WIN_RIGHT_COL : SCREEN[z1,s1] := Fuellwort
    MOV   AL,[WIN_BOT_ROW]
    MOV   [F06_ROW],AL
    MOV   AL,[WIN_LEFT_COL]
    MOV   [F06_COL],AL
.f_loop:
    MOV   AL,[F06_COL]
    CMP   AL,[WIN_RIGHT_COL]
    JA    .f_done
    MOV   AL,[F06_ROW]
    MOV   BL,[F06_COL]
    CALL  SCREEN_PTR
    MOV   AX,[F06_FILL_WORD]
    MOV   [ES:DI],AX
    INC   byte [F06_COL]
    JMP   .f_loop
.f_done:
    INC   byte [F06_SCROLL_IDX]
    JMP   .adz_loop

.done:
    RET


; ----------------------------------------------------------------------------
;  PROCEDURE PROC_SCROLL_DOWN  (Scroll Down, AH=07H)
; ----------------------------------------------------------------------------
PROC_SCROLL_DOWN:

    MOV   AL,FILL_CHAR
    MOV   AH,[OUT_ATTR]

    MOV   [F07_FILL_WORD],AX

    MOV   AL,[WIN_BOT_ROW]
    SUB   AL,[WIN_TOP_ROW]
    INC   AL
    MOV   [F07_WIN_HEIGHT],AL

    MOV   AL,[COUNT_LO]
    OR    AL,AL
    JNZ   .scroll
    CALL  SCREEN_CLEAR
    RET

.scroll:
    MOV   byte [F07_SCROLL_IDX],1
.adz_loop:
    MOV   AL,[F07_SCROLL_IDX]
    CMP   AL,[COUNT_LO]
    JA    .done
    MOV   AL,[F07_WIN_HEIGHT]
    CMP   AL,1
    JBE   .fill
    MOV   byte [F07_WIN_ROW_IDX],1
.afz_loop:
    MOV   AL,[F07_WIN_ROW_IDX]
    CMP   AL,[F07_WIN_HEIGHT]
    JA    .fill
    ; z1 := WIN_BOT_ROW - AFZ + 1
    MOV   AL,[WIN_BOT_ROW]
    SUB   AL,[F07_WIN_ROW_IDX]
    INC   AL
    MOV   [F07_ROW],AL
    ; FOR s1 := WIN_LEFT_COL TO WIN_RIGHT_COL : SCREEN[z1,s1] := SCREEN[z1-1,s1]
    MOV   AL,[WIN_LEFT_COL]
    MOV   [F07_COL],AL
.s_loop:
    MOV   AL,[F07_COL]
    CMP   AL,[WIN_RIGHT_COL]
    JA    .s_done
    MOV   AL,[F07_ROW]
    MOV   BL,[F07_COL]
    CALL  SCREEN_PTR
    MOV   AX,[ES:DI-ROW_BYTES]          ; SCREEN[z1-1,s1]
    MOV   [ES:DI],AX
    INC   byte [F07_COL]
    JMP   .s_loop
.s_done:
    INC   byte [F07_WIN_ROW_IDX]
    JMP   .afz_loop

.fill:
    ; z1 := WIN_TOP_ROW ; FOR s1 := WIN_LEFT_COL TO WIN_RIGHT_COL : SCREEN[z1,s1] := Fuellwort
    MOV   AL,[WIN_TOP_ROW]
    MOV   [F07_ROW],AL
    MOV   AL,[WIN_LEFT_COL]
    MOV   [F07_COL],AL
.f_loop:
    MOV   AL,[F07_COL]
    CMP   AL,[WIN_RIGHT_COL]
    JA    .f_done
    MOV   AL,[F07_ROW]
    MOV   BL,[F07_COL]
    CALL  SCREEN_PTR
    MOV   AX,[F07_FILL_WORD]
    MOV   [ES:DI],AX
    INC   byte [F07_COL]
    JMP   .f_loop
.f_done:
    INC   byte [F07_SCROLL_IDX]
    JMP   .adz_loop

.done:
    RET


; ----------------------------------------------------------------------------
;  PROCEDURE PROC_READ_CHAR_ATTR  (Zeichen+Attribut an Cursor lesen, AH=08H)
; ----------------------------------------------------------------------------
PROC_READ_CHAR_ATTR:

    MOV   AX,BDA_SEG
    MOV   ES,AX
    MOV   AL,[ES:BDA_CUR_ROW_OFF]
    MOV   BL,[ES:BDA_CUR_COL_OFF]
    CALL  SCREEN_PTR
    MOV   AL,[ES:DI]                  ; BS_Zeichen
    MOV   [OUT_CHAR],AL
    MOV   AL,[ES:DI+1]                    ; BS_Attribut
    MOV   [OUT_ATTR],AL

    RET


; ----------------------------------------------------------------------------
;  PROCEDURE PROC_WRITE_CHAR_ATTR_REP  (Zeichen+Attribut wiederholt schreiben, AH=09H)
; ----------------------------------------------------------------------------
PROC_WRITE_CHAR_ATTR_REP:
    ; Anzahl = COUNT_HI*256 + COUNT_LO  (Integer, signed)
    MOV   AH,[COUNT_HI]
    MOV   AL,[COUNT_LO]
    MOV   [F09_COUNT],AX

    ; Zeichen+Attribut an Cursorposition schreiben
    CALL  WRITE_CUR_CHAR_ATTR

    ; IF Anzahl > 1
    MOV   AX,[F09_COUNT]
    CMP   AX,1
    JLE   .done                         ; signed: Anzahl <= 1 -> Ende

    ; Cursor sichern
    MOV   BX,BDA_SEG
    MOV   ES,BX
    MOV   AL,[ES:BDA_CUR_COL_OFF]
    MOV   [F09_SAVED_COL],AL
    MOV   AL,[ES:BDA_CUR_ROW_OFF]
    MOV   [F09_SAVED_ROW],AL

    ; FOR Zaehler := 2 TO Anzahl
    MOV   word [F09_COUNTER],2
.loop:
    MOV   AX,[F09_COUNTER]
    CMP   AX,[F09_COUNT]
    JG    .restore                      ; signed: Zaehler > Anzahl -> Ende
    CALL  CUR_RIGHT
    CALL  WRITE_CUR_CHAR_ATTR
    INC   word [F09_COUNTER]
    JMP   .loop

.restore:
    MOV   BX,BDA_SEG
    MOV   ES,BX
    MOV   AL,[F09_SAVED_COL]
    MOV   [ES:BDA_CUR_COL_OFF],AL
    MOV   AL,[F09_SAVED_ROW]
    MOV   [ES:BDA_CUR_ROW_OFF],AL
.done:
    RET


; ----------------------------------------------------------------------------
;  PROCEDURE PROC_WRITE_CHAR_REP  (nur Zeichen wiederholt schreiben, AH=0AH)
; ----------------------------------------------------------------------------
PROC_WRITE_CHAR_REP:
    MOV   AH,[COUNT_HI]
    MOV   AL,[COUNT_LO]
    MOV   [F0A_COUNT],AX

    ; nur Zeichen an Cursorposition schreiben
    CALL  WRITE_CUR_CHAR

    MOV   AX,[F0A_COUNT]
    CMP   AX,1
    JLE   .done

    MOV   BX,BDA_SEG
    MOV   ES,BX
    MOV   AL,[ES:BDA_CUR_COL_OFF]
    MOV   [F0A_SAVED_COL],AL
    MOV   AL,[ES:BDA_CUR_ROW_OFF]
    MOV   [F0A_SAVED_ROW],AL

    MOV   word [F0A_COUNTER],2
.loop:
    MOV   AX,[F0A_COUNTER]
    CMP   AX,[F0A_COUNT]
    JG    .restore
    CALL  CUR_RIGHT
    CALL  WRITE_CUR_CHAR
    INC   word [F0A_COUNTER]
    JMP   .loop

.restore:
    MOV   BX,BDA_SEG
    MOV   ES,BX
    MOV   AL,[F0A_SAVED_COL]
    MOV   [ES:BDA_CUR_COL_OFF],AL
    MOV   AL,[F0A_SAVED_ROW]
    MOV   [ES:BDA_CUR_ROW_OFF],AL
.done:
    RET


; ----------------------------------------------------------------------------
;  PROCEDURE PUT_CHAR_ADVANCE  (Zeichen schreiben + Cursor weiter)
; ----------------------------------------------------------------------------
PUT_CHAR_ADVANCE:
    CALL  WRITE_CUR_CHAR
    CALL  CUR_RIGHT
    RET


; ----------------------------------------------------------------------------
;  PROCEDURE PROC_TELETYPE  (Teletype-Zeichen verarbeiten, AH=0EH)
;  CASE OUT_CHAR OF ...
; ----------------------------------------------------------------------------
PROC_TELETYPE:
    MOV   AL,[OUT_CHAR]

    CMP   AL,01H
    JNE   .c04
    CALL  CUR_HOME                      ; auf Pos 0,0
    RET
.c04:
    CMP   AL,04H
    JNE   .c05
    CALL  CUR_RIGHT                     ; nach rechts
    RET
.c05:
    CMP   AL,05H
    JNE   .c09
    CALL  CUR_UP                        ; nach oben
    RET
.c09:
    CMP   AL,09H
    JNE   .c0a
    ; CUR_SPALTE := 8 * (CUR_SPALTE div 8)  == CUR_SPALTE AND 0F8h
    MOV   AX,BDA_SEG
    MOV   ES,AX
    MOV   AL,[ES:BDA_CUR_COL_OFF]
    AND   AL,0F8H
    MOV   [ES:BDA_CUR_COL_OFF],AL
    RET
.c0a:
    CMP   AL,0AH
    JNE   .c0c
    CALL  CUR_DOWN                      ; LF
    RET
.c0c:
    CMP   AL,0CH
    JNE   .c0d
    CALL  SCREEN_CLEAR                  ; CLS
    RET
.c0d:
    CMP   AL,0DH
    JNE   .c13
    ; CUR_SPALTE := 0  (CR)
    MOV   AX,BDA_SEG
    MOV   ES,AX
    XOR   AL,AL
    MOV   [ES:BDA_CUR_COL_OFF],AL
    RET
.c13:
    CMP   AL,13H
    JNE   .c18
    CALL  CUR_LEFT                      ; links
    RET
.c18:
    CMP   AL,18H
    JNE   .celse
    CALL  CUR_DOWN                      ; unten
    RET
.celse:
    CALL  PUT_CHAR_ADVANCE              ; sonst: Zeichen ausgeben
    RET







; ----------------------------------------------------------------------------
;  Globale Byte-Variablen auf FESTEN Offsets 03h..0Ch
;  (vom Pascal-Modul hart als ABSOLUTE [E000:offset] adressiert)
; ----------------------------------------------------------------------------
OUT_CHAR             DB  00             ; AusgabeZeichen
OUT_ATTR             DB  00             ; AusgabeAttribut
WIN_TOP_ROW          DB  00             ; Ecke Oben Links  - Zeile
WIN_LEFT_COL         DB  00             ; Ecke Oben Links  - Spalte
WIN_BOT_ROW          DB  00             ; Ecke Unten Rechts- Zeile
WIN_RIGHT_COL        DB  00             ; Ecke Unten Rechts- Spalte
RESERVED_ROW_09H     DB  00             ; 
RESERVED_COL_0AH     DB  00             ; 
COUNT_LO             DB  00             ; Anzahl Zeilen (FKT06) / LO-Byte (FKT09)
COUNT_HI             DB  00             ; HI-Byte (FKT09)







; ============================================================================
;  Statische Daten (Pascal-Locals; keine Rekursion -> statisch zulaessig)
; ============================================================================
F06_FILL_WORD        DW  0
F06_WIN_HEIGHT       DB  0
F06_SCROLL_IDX       DB  0
F06_WIN_ROW_IDX      DB  0
F06_ROW              DB  0
F06_COL              DB  0

F07_FILL_WORD        DW  0
F07_WIN_HEIGHT       DB  0
F07_SCROLL_IDX       DB  0
F07_WIN_ROW_IDX      DB  0
F07_ROW              DB  0
F07_COL              DB  0

F09_COUNT            DW  0
F09_COUNTER          DW  0
F09_SAVED_COL        DB  0
F09_SAVED_ROW        DB  0

F0A_COUNT            DW  0
F0A_COUNTER          DW  0
F0A_SAVED_COL        DB  0
F0A_SAVED_ROW        DB  0

; ============================================================================
;  ENDE
; ============================================================================
