
; *********************************
; *** INT 10,0 - Set Video Mode ***
; *********************************



; ******************************
; *  Speichervariablen VIDEO   *
; ******************************



; ****************************************
; * Vereinbarungsteil fuer VIDEO INT 10H *
; ****************************************

; 01..99 -> SEND 2 PARAM
; Funktionen, die 2 Parameter an das VIDEO-Terminal senden
VIDEO_SET_CURSOR_POS    EQU  01

VIDEO_Set_Video_Mode    EQU  02

VIDEO_PAR_Scroll_01     EQU  03
VIDEO_PAR_Scroll_02     EQU  04
VIDEO_PAR_Scroll_Up     EQU  05

VIDEO_CONOUT            EQU  06

VIDEO_PAR_Scroll_Down   EQU  08

VIDEO_CONOUT_09H_01     EQU  10
VIDEO_CONOUT_09H_02     EQU  11

VIDEO_CONOUT_0AH_01     EQU  12
VIDEO_CONOUT_0AH_02     EQU  14



; 101..199 -> RECEIVE 2 PARAM
; Funktionen, die 2 Parameter vom VIDEO-Terminal empfangen
VIDEO_GET_CURSOR_POS    EQU  101
VIDEO_GET_ChrAtt_CurPos EQU  102





; ------------------------------------------------------


INT_10:  ;Video


    CMP    AH,00H        ; Bildschirmmodus wählen (AH = 00H)
    JNE    INT_10_01
    JMP    INT10_AH_00


INT_10_01:
    CMP    AH,01H        ; Cursor-Größe definieren (AH = 01H)
    JNE    INT_10_02
    JMP    INT10_AH_01


INT_10_02:
    CMP    AH,02H        ; Cursor positionieren (AH = 02H)
    JNE    INT_10_03
    JMP    INT10_AH_02

INT_10_03:
    CMP    AH,03H        ; Cursorposition ermitteln (AH = 03H)
    JNE    INT_10_05
    JMP    INT10_AH_03

INT_10_05:
    CMP    AH,05H        ; Bildschirmseite selektieren (AH = 05H)
    JNE    INT_10_06
    JMP    INT10_AH_05


INT_10_06:
    CMP    AH,06H        ; Bildschirmfenster Scroll Up (AH = 06H)
    JNE    INT_10_07
    JMP    INT10_AH_06


INT_10_07:
    CMP    AH,07H        ; Bildschirmfenster Scroll Down (AH = 07H)
    JNE    INT_10_08
    JMP    INT10_AH_07


INT_10_08:
    CMP    AH,08H        ; Zeichen und Attribute an Cursorposition lesen (AH = 08H)
    JNE    INT_10_09
    JMP    INT10_AH_08


INT_10_09:
    CMP    AH,09H        ; Zeichen und Attribut an Cursorposition schreiben (AH = 09H)
    JNE    INT_10_0A
    JMP    INT10_AH_09


INT_10_0A:
    CMP    AH,0AH        ; Zeichen an Cursorposition schreiben (AH = 0AH)
    JNE    INT_10_0B
    JMP    INT10_AH_0A


INT_10_0B:
    CMP    AH,0BH        ; Farbpalette für Grafik setzen (AH = 0BH)
    JNE    INT_10_0E
    JMP    INT10_AH_0B


INT_10_0E:
    CMP    AH,0EH        ; Zeichen ausgeben (AH = 0EH)
    JNE    INT_10_0F
    JMP    INT10_AH_0E


INT_10_0F:
    CMP    AH,0FH        ; Bildschirmstatus lesen (AH = 0FH)
    JNE    INT_10_11
    JMP    INT10_AH_0F


INT_10_11:
    CMP    AH,11H        ; 
    JNE    INT_10_12
    JMP    INT10_AH_11


INT_10_12:
    CMP    AH,12H        ; EGA
    JNE    INT_10_1A
    JMP    INT10_AH_12


INT_10_1A:
    CMP    AH,01AH       ;
    JNE    INT_10_FE
    JMP    INT10_AH_1A


INT_10_FE:
    CMP    AH,0FEH       ;
    JNE    INT_10_NOT_FOUND
    JMP    INT10_AH_FE






; Interrupt-Funktion nicht gefunden
INT_10_NOT_FOUND:

%if ERROR_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,10H
    CALL   DEBUG_TRACE_UNSUPPORTED
    POP    BP
    POP    AX
%endif

    IRET    ;RETURN FROM INTERRUPT




; ******************************************************
; * Bildschirmmodus wählen (AH = 00H)
;   (Set Video Mode)
; ******************************************************
; Dieser Aufruf ermöglicht es, den Bildschirmmodus
; (Mono, Color, Grafik) einzustellen.
; Der Wert des Registers AL selektiert den Modus.
;
; AL = 0 Text 40 Zeichen x 25 Zeilen monochrom
; AL = 1 Text 40x25 color
; AL = 2 Text 80x25 monochrom
; AL = 3 Text 80x25 color
; AL = 4 Grafik 320x200 color
; AL = 5 Grafik 320x200 monochrom
; AL = 6 Grafik 640x200 monochrom
; AL = 7 CRT Modus 80x25 monochrom (intern)
;
; Eingabe: AL: Bildschirmmodus
; Ausgabe: keine
;
; ************************************
; Input: AH = 00h
;        AL = Video mode, where:
;             00h-07h - Valid values
;             08h-0Ch - Reserved
;             0Dh-13h - Valid values
; Output: AL = Video mode, where:
;             20h - Mode is greater than 7
;             30h - Mode is from 0-5 or 7
;             3Fh - Mode is mode 6
;
; ************************************
; (AH) = 00H - Set Video Mode
; (AL) - Requested video mode
; ************************************


INT10_AH_00:

%if DEBUG_INT10
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,10H
    CALL   Sende_DEBUG_INT_ok
    POP    BP
    POP    AX
%endif

    PUSH   AX
    PUSH   BX

    MOV    BL,AL    ; 1.Parameter <- Bildschirmmodus
    MOV    AL,VIDEO_Set_Video_Mode
    CALL   VIDEO_PARAM_SEND



    POP    BX
    POP    AX


;    MOV    AL, 30H   ; 30h - Mode is from 0-5 or 7



%if DEBUG_INT10
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,10H
    CALL   Sende_DEBUG_INT_Rueckgabe
    POP    BP
    POP    AX
%endif


    IRET    ;RETURN FROM INTERRUPT





; ******************************************************
; * Cursor-Groesse definieren (AH = 01H)
;   (Set Text Mode Cursor Size)
; ******************************************************
; Dieser Aufruf dient dazu, die Groesse des sichtbaren
; Cursors zu definieren. Die Form ist abhängig von der
; Zahl der Linien und wird durch das Register CX spezifiziert.
; 
; Eingabe: AH: 01H (Cursor Size)
;          CH: Bit 0-4 Startzeile Cursor
;          CL: Bit 0-4 Endzeile Cursor
;
; Ausgabe: keine
;
; ************************************
; Input/Output
; Input: AH = 01h
;        CH = Top scan line, where:
;             Bits 7-6 = 00h (must be OOh, otherwise cursor blinking becomes erratic)
;             Bit 5 = To shut cursor off
;             Bits 4-0 = Top scan line
;        CL = Bottom scan line, where:
;             Bit 7 = Undefined
;             Bits 6-5 = Show cursor
;             Bits 4-0 = Lower scan line
; Output: None
; ************************************
INT10_AH_01:

%if DEBUG_INT10
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,10H
    CALL   Sende_DEBUG_INT_ok
    POP    BP
    POP    AX
%endif

; wird ignoriert

    IRET    ;RETURN FROM INTERRUPT




; ************************************
; * Cursor positionieren (AH = 02H)
;   (Set Cursor Position)
; ************************************
; Der Cursor laesst sich mit dieser Funktion
; auf dem Bildschirm positionieren. 
; Die Koordinaten werden durch das 
; DX-Register angegeben. Die Position (0,0) 
; befindet sich in der linken oberen Bildschirmecke.
;
; Eingabe: AH: 02H (Set Cursor)
;          BH: Bildschirmseite
;          DH: Zeilennummer
;          DL: Spaltennummer
;
; Ausgabe: keine
;
; ************************************
; Input/Output
; Input: AH = 02h
;        BH Display page number (see Function AH = 05h)
;        DH = Row (0 is top row of screen)
;        DL = Column (0 is leftmost column)
; Output: AX = 00h
; ************************************
;
INT10_AH_02:

%if DEBUG_INT10
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,10H
    CALL   Sende_DEBUG_INT_ok
    POP    BP
    POP    AX
%endif


    PUSH   BX

    MOV    AL, VIDEO_SET_CURSOR_POS
    MOV    BL, DL ; Spaltennummer als 1.Parameter
    MOV    BH, DH ; Zeilennummer als 2.Parameter

    CALL   VIDEO_PARAM_SEND

    POP    BX


;    MOV    AX, 0


%if DEBUG_INT10
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,10H
    CALL   Sende_DEBUG_INT_Rueckgabe
    POP    BP
    POP    AX
%endif


    IRET    ;RETURN FROM INTERRUPT




; ************************************
; * Cursorposition ermitteln (AH = 03H)
;   (Read Current Cursor Position)
; ************************************
; Die Position des Cursors innerhalb einer Bildschirmseite
; laesst sich mit der Unterfunktion AH = 3 abfragen. 
; Das Register BH spezifiziert dabei die Bildschirmseite (bei Grafik = 0).
;
; Die Funktion liefert als Ergebnis Lage und Größe des Cursors zurück.
; Die Cursorgroesse findet sich analog zur Funktion AH = 1 im CX-Register
;
; Eingabe: AH: 03H (Get Cursor)
;          BH: Bildschirmseite
;
; Ausgabe: DH: Zeilennummer
;          DL: Spaltennummer
;          CH: Startzeile Cursor
;          CL: Endzeile Cursor
;
; ************************************
; Input/Output
; Input: AH = 03h
;        BH = Display page number (zero-based)
; Output: AX = 00h
;         CH = Starting cursor scan line
;         CL = Ending cursor scan line
;         DH = Row number
;         DL = Column number
; ************************************
;
INT10_AH_03:

%if DEBUG_INT10
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,10H
    CALL   Sende_DEBUG_INT_ok
    POP    BP
    POP    AX
%endif

    PUSH   AX
    PUSH   BX

    MOV    AL, VIDEO_GET_CURSOR_POS
    CALL   VIDEO_PARAM_RESV

    MOV    DL,BL ; Parameter1 = Spaltenummer
    MOV    DH,BH ; Parameter2 = Zeilennummer

    POP    BX
    POP    AX

; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    MOV    CX,0607H

%if DEBUG_INT10
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,10H
    CALL   Sende_DEBUG_INT_Rueckgabe
    POP    BP
    POP    AX
%endif

    IRET    ;RETURN FROM INTERRUPT





; ************************************
; * Bildschirmseite selektieren (AH = 05H)
;   (Select New Video Page)
; ************************************
; Befindet sich der Bildschirmadapter im Textmodus (siehe Funktion AH = 00H), läßt sich
; mit dieser Funktion die aktuelle Bildschirmseite umschalten. Der Wert des Registers AL
; bestimmt die Bildschirmseite.
; Im 40x25-Zeichen-Modus existieren 8 Seiten, während der 80x25-Modus nur 4 Seiten
; erlaubt.
;
; Eingabe: AH: 05H (Set Page)
;          AL: Bildschirmseite 
;
; Ausgabe: keine
;
; ************************************
; Input/Output
; Input: AH = OSh
;        AL = New page number (zero-based)
; Output: None
; ************************************
;
INT10_AH_05:

%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,10H
    CALL   DEBUG_TRACE_UNSUPPORTED
    POP    BP
    POP    AX
%endif
;
; wird ignoriert und soll nicht erfolgen !!!
;

%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,10H
    CALL   Sende_DEBUG_INT_Rueckgabe_Fehler
    POP    BP
    POP    AX
%endif

    IRET    ;RETURN FROM INTERRUPT





; *****************************************
; * Bildschirmfenster Scroll Up (AH = 06H)
; *****************************************
; (Scroll Current Page Up)
; Innerhalb der aktiven Bildschirmseite läßt sich im Textmodus
; ein Fenster einblenden, in dem mit dieser Funktion der Text
; nach oben gescrollt wird. Dabei läßt sich der Ausschnitt
; auf den kompletten Bildschirm vergrößern, um die Scrollfunktion
; auf die gesamte Seite auszudehnen. Im unteren Fensterbereich
; werden beim Scroll Leerzeilen eingefügt. 
;
; Eingabe: AH: 06H (Scroll Up)
;          AL: Anzahl der Zeilen, um die nach oben geschoben wird
;              (0 = clear, CH, CL, DH, DL are used)
;          BH: Attribut der Leerzeile
;          CH: Eckzeile oben links
;          CL: Eckspalte oben links
;          DH: Eckzeile unten rechts
;          DL: Eckspalte unten rechts
;
; Ausgabe: keine
;
; *****************************************
; Input/Output
; Input: AH = 06h Scroll current page up
;        AL = Scroll distance in character rows
;             (0 blanks entire scroll area)
;        BH = Attribute to use on blanked lines
;        CH = Top row of scroll window
;        CL = Left column of scroll window
;        DH Bottom row of scroll window
;        DL = Right column of scroll window
; Output: None
; *****************************************
;
INT10_AH_06:

%if DEBUG_INT10
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,10H
    CALL   Sende_DEBUG_INT_ok
    POP    BP
    POP    AX
%endif


    PUSH   AX
    PUSH   BX
    PUSH   CX
    PUSH   DX


; 1. Durchgang: P1=Anzahl der Zeilen
;               P2=Attribut der Leerzeile
    ; Uebergabe: BH=2.Parameter <- Attribut der Leerzeile
    MOV    BL,AL    ; BL=1.Parameter <- Anzahl der Zeilen
    MOV    AL,VIDEO_PAR_Scroll_01
    CALL   VIDEO_PARAM_SEND


; 2. Durchgang: P1=Eckspalte oben links
;               P2=Eckzeile oben links
    MOV    BL,CL    ; BL=1.Parameter <- Eckspalte oben links
    MOV    BH,CH    ; BH=2.Parameter <- Eckzeile oben links
    MOV    AL,VIDEO_PAR_Scroll_02
    CALL   VIDEO_PARAM_SEND


; 3. Durchgang: P1=Eckspalte unten rechts
;               P2=Eckzeile unten rechts
    MOV    BL,DL    ; BL=1.Parameter <- Eckspalte unten rechts
    MOV    BH,DH    ; BH=2.Parameter <- Eckzeile unten rechts
    MOV    AL,VIDEO_PAR_Scroll_Up
    CALL   VIDEO_PARAM_SEND



    POP    DX
    POP    CX
    POP    BX
    POP    AX



    IRET    ;RETURN FROM INTERRUPT







; *****************************************
; * Bildschirmfenster Scroll Down (AH = 07H)
; *****************************************
; Innerhalb der aktiven Bildschirmseite läßt sich im Textmodus
; ein Fenster einblenden, in dem mit dieser Funktion der Text
; nach oben gescrollt wird. Dabei läßt sich der Ausschnitt
; auf den kompletten Bildschirm vergrößern, um die Scrollfunktion
; auf die gesamte Seite auszudehnen. Im unteren Fensterbereich
; werden beim Scroll Leerzeilen eingefügt. 
;
; Eingabe: AH: 07H (Scroll Down)
;          AL: Anzahl der Zeilen, um die nach oben geschoben wird
;              (0 = clear, CH, CL, DH, DL are used)
;          BH: Attribut der Leerzeile
;          CH: Eckzeile oben links
;          CL: Eckspalte oben links
;          DH: Eckzeile unten rechts
;          DL: Eckspalte unten rechts
;
; Ausgabe: keine
;
; *****************************************
; Input/Output
; Input: AH = 07h Scroll current page down
;        AL = Scroll distance in character rows
;             (0 blanks entire scroll area)
;        BH = Attribute to use on blanked lines
;        CH = Top row of scroll window
;        CL = Left column of scroll window
;        DH Bottom row of scroll window
;        DL = Right column of scroll window
; Output: None
; *****************************************

INT10_AH_07:

%if DEBUG_INT10
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,10H
    CALL   Sende_DEBUG_INT_ok
    POP    BP
    POP    AX
%endif


    PUSH   AX
    PUSH   BX
    PUSH   CX
    PUSH   DX


; 1. Durchgang: P1=Anzahl der Zeilen
;               P2=Attribut der Leerzeile
    ; Uebergabe: BH=2.Parameter <- Attribut der Leerzeile
    MOV    BL,AL    ; BL=1.Parameter <- Anzahl der Zeilen
    MOV    AL,VIDEO_PAR_Scroll_01
    CALL   VIDEO_PARAM_SEND


; 2. Durchgang: P1=Eckspalte oben links
;               P2=Eckzeile oben links
    MOV    BL,CL    ; BL=1.Parameter <- Eckspalte oben links
    MOV    BH,CH    ; BH=2.Parameter <- Eckzeile oben links
    MOV    AL,VIDEO_PAR_Scroll_02
    CALL   VIDEO_PARAM_SEND


; 3. Durchgang: P1=Eckspalte unten rechts
;               P2=Eckzeile unten rechts
    MOV    BL,DL    ; BL=1.Parameter <- Eckspalte unten rechts
    MOV    BH,DH    ; BH=2.Parameter <- Eckzeile unten rechts
    MOV    AL,VIDEO_PAR_Scroll_Down
    CALL   VIDEO_PARAM_SEND



    POP    DX
    POP    CX
    POP    BX
    POP    AX



    IRET    ;RETURN FROM INTERRUPT






; ***********************************************************
; * Zeichen und Attribute an Cursorposition lesen (AH = 08H)
;   (Read Character/Attribute from Screen)
; ***********************************************************
; Im Textmodus läßt sich das an der aktuellen Cursorposition
; abgespeicherte Zeichen, sowie das zugehörige Attributbyte lesen.
; Der Inhalt des BH-Registers spezifiziert dabei die Bildschirmseite.
; Das Ergebnis wird im AX-Register zurückgegeben
;
; Eingabe: AH: 08H (Get Char Attribut)
;          BH: Bildschirmseite (Textmodus)
;
; Ausgabe: AL: gelesenes Zeichen
;          AH: Attributbyte (Textmodus)
;
; *****************************************
; Input/Output
; Input: AH = 08h
;        BH = Display page (refer to the Video Modes heading for the
;                           maximum pages per mode)
; Output: AH = Attribute (text modes only)
;         AL = Character read
; *****************************************
;
INT10_AH_08:

%if DEBUG_INT10
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,10H
    CALL   Sende_DEBUG_INT_ok
    POP    BP
    POP    AX
%endif

    PUSH   BX


    MOV    AL, VIDEO_GET_ChrAtt_CurPos
    CALL   VIDEO_PARAM_RESV

    MOV    AL,BL ; Parameter1 = gelesenes Zeichen
    MOV    AH,BH ; Parameter2 = Attributbyte (Textmodus)


    POP    BX



%if DEBUG_INT10
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,10H
    CALL   Sende_DEBUG_INT_Rueckgabe
    POP    BP
    POP    AX
%endif


    IRET    ;RETURN FROM INTERRUPT





; ***********************************************************
; * Zeichen und Attribut an Cursorposition schreiben (AH = 09H)
;   (WRITE CHARACTER AND ATTRIBUTE AT CURSOR POSITION)
; ***********************************************************
;
; Hinweis: Funktion 09 soll vorrangig fuer den Grafikmodus
;          genutzt werden
;
; Eingabe: AH: 09H (Set Char & Attribut)
;          AL: Zeichencode
;          BH: Bildschirmseite der Aus-
;              gabe (nur im Textmodus)
;          BL: Attributbyte des Zeichens
;          CX: Zahl der Kopien
;
; Ausgabe: keine
;
; ******************************
; AL = ASCII character to write
; BH = display page  (or mode 13h, background pixel value)  IGNORED
; BL = character attribute (text) foreground color (graphics) 
; CX = count of characters to write (CX >= 1)  IGNORED
; ******************************
;
INT10_AH_09:

%if DEBUG_INT10
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,10H
    CALL   Sende_DEBUG_INT_ok
    POP    BP
    POP    AX
%endif



    PUSH   AX
    PUSH   BX
    PUSH   CX


    MOV    BH, BL ; Attributbyte des Zeichens (text) als 2.Parameter
    MOV    BL, AL ; Zeichencode als 1.Parameter


    MOV    AL, VIDEO_CONOUT_09H_01

    CALL   VIDEO_PARAM_SEND


    MOV    BH, CH ; Zahl der Kopien HWT als 2.Parameter
    MOV    BL, CL ; Zahl der Kopien NWT als 1.Parameter

    MOV    AL, VIDEO_CONOUT_09H_02

    CALL   VIDEO_PARAM_SEND



    POP    CX
    POP    BX
    POP    AX




%if DEBUG_INT10
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,10H
    CALL   Sende_DEBUG_INT_Rueckgabe
    POP    BP
    POP    AX
%endif


    IRET    ;RETURN FROM INTERRUPT







; ***********************************************************
; * Zeichen an Cursorposition schreiben (AH = 0AH)
;   (Write Character Only to Screen)
; ***********************************************************
;
; Hinweis: Funktion 0A soll vorrangig fuer den Textkmodus
;          genutzt werden
;
; Für die Fälle, wo lediglich Zeichen ohne Attributbyte ausgegeben
; werden müssen, läßt sich diese Funktion benutzen.
; Das im Bildschirmspeicher gesetzte Attributbyte
; bleibt beim Schreibvorgang erhalten.

; Eingabe: AH: 0AH (Write Char)
;          AL: Zeichencode
;          BH: Bildschirmseite der Aus-
;              gabe (nur im Textmodus)
;          CX: Zahl der Kopien
;
; Ausgabe: keine
;
; ******************************
; WRITE CHARACTER AT CURSOR POSITION - 0AH
; Input/Output
; Input: AH = OAh
;        AL = Character to write (ASCII codes)
;        BH = Display page (text modes only)
;        CX = Repeat count
; Output: None
; ******************************
;
INT10_AH_0A:

%if DEBUG_INT10
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,10H
    CALL   Sende_DEBUG_INT_ok
    POP    BP
    POP    AX
%endif




    PUSH   AX
    PUSH   BX
    PUSH   CX


    MOV    BL, AL ; Zeichencode als 1.Parameter


    MOV    AL, VIDEO_CONOUT_0AH_01

    CALL   VIDEO_PARAM_SEND


    MOV    BH, CH ; Zahl der Kopien HWT als 2.Parameter
    MOV    BL, CL ; Zahl der Kopien NWT als 1.Parameter

    MOV    AL, VIDEO_CONOUT_0AH_02

    CALL   VIDEO_PARAM_SEND



    POP    CX
    POP    BX
    POP    AX




%if DEBUG_INT10
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,10H
    CALL   Sende_DEBUG_INT_Rueckgabe
    POP    BP
    POP    AX
%endif

    IRET    ;RETURN FROM INTERRUPT





; ***************
; * SET PALETTE *
; ***************
INT10_AH_0B:

%if ERROR_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,10H
    CALL   DEBUG_TRACE_UNSUPPORTED
    POP    BP
    POP    AX
%endif

; wird nicht unterstuetzt

    IRET    ;RETURN FROM INTERRUPT





; ***********************************************************
; * Zeichen ausgeben (AH = 0EH)
;   (Write Teletype to Active Page)
; ***********************************************************
;
; Mit dieser Funktion wird ein Teletype-Interface für die
; Bildschirmausgabe simuliert. 
; Pro ausgegebenem Zeichen wird der Cursor um eine Stelle
; weiter bewegt. Die Funktion erwartet folgende Eingaben
;
; Eingabe: AL: auszugebendes ASCII-Zeichen
;          BL: Vordergrundfarbe im Grafikmodus
;          BH: Ausgabeseite im Textmodus
;
; Ausgabe: keine
;
; ************************************
;Diese Funktion lässt die Anzeige wie ein serielles Terminal
; erscheinen. Das Zeichen in AL wird in den Videospeicher
; geschrieben, um es auf der aktiven Seite an der aktuellen
; Cursorposition zu platzieren, und der Cursor wird zur nächsten
; Zeichenposition bewegt (Scrollen ist erforderlich). 
; Die Bildschirmbreite ist eine Funktion des aktuell aktiven Videomodus.
;
; 
;
; Input/Output
; Input: AH = OEh
;        AL = Character to write
;        BL = Foreground color (graphics modes only)
;        BH = Active page
; Output: None
; ************************************
;
INT10_AH_0E:

%if DEBUG_INT10
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,10H
    CALL   Sende_DEBUG_INT_ok
    POP    BP
    POP    AX
%endif


; BH: Ausgabeseite im Textmodus wird ignoriert

    PUSH   AX
    PUSH   BX


    MOV    BL, AL ; auszugebendes ASCII-Zeichen als 1.Parameter
    MOV    BH, BL ; Vordergrundfarbe im Grafikmodus als 2.Parameter

    MOV    AL, VIDEO_CONOUT

    CALL   VIDEO_PARAM_SEND


    POP    BX
    POP    AX

    IRET    ;RETURN FROM INTERRUPT






; ****************************************
; * Bildschirmstatus lesen (AH = 0FH)
;   (Return Video Status)
; ****************************************
; Als Komplement zur Funktion AH = 0 (setze Bildschirmmodus)
; laesst sich hier der Modus wieder auslesen.
;
; Eingabe: AH = 0FH
;
; Ausgabe: AL: Bildschirmmodus
;          AH: Bildschirmspalten (40 /80)
;          BH: aktuelle Bildschirmseite 
;
; ****************************************
; Input/Output
; Input: AH = OFh
; Output: AH = Number of columns on screen from the
;              screen width byte (40:4Ah)
;         AL = Current mode from the video mode setting byte (40:49h)
;         BH = Active display page number from the display
;              page byte (40:62h)
; ****************************************
;
INT10_AH_0F:

%if DEBUG_INT10
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,10H
    CALL   Sende_DEBUG_INT_ok
    POP    BP
    POP    AX
%endif

; Ausgabe des Festwertes nach DOSBOX

    MOV    AL,03       ; Bildschirmmodus
    MOV    AH,80       ; Bildschirmspalten (40 /80)
    MOV    BH,00       ; aktuelle Bildschirmseite

%if DEBUG_INT10
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,10H
    CALL   Sende_DEBUG_INT_Rueckgabe
    POP    BP
    POP    AX
%endif

    IRET    ;RETURN FROM INTERRUPT





; ****************************************
; ****************************************
; *  Funktion 11h: GET FONT INFORMATION (EGA, MCGA, VGA)
; ****************************************
; VIDEO - GRAPHICS-MODE CHARACTER GENERATOR FUNCTIONS (PS, EGA, VGA)
; Function: AH = 11h Load Character Generator
; Als Komplement zur Funktion AH = 0 (setze Bildschirmmodus)
; laesst sich hier der Modus wieder auslesen.
;
; Eingabe: AH=11H
;
; Ausgabe: 
; ****************************************
INT10_AH_11:

    CMP    AL,30H
    JZ     INT10_AH_11_AL_30

%if ERROR_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,10H
    CALL   DEBUG_TRACE_UNSUPPORTED
    POP    BP
    POP    AX
%endif

    IRET    ;RETURN FROM INTERRUPT



; ------------------------------------
; - Unterfunktion AH = 11H, AL = 30H -
; ------------------------------------
; Eingabe: AX = 1130h
;          BH = pointer specifier
;               00h INT 1Fh pointer
;               01h INT 43h pointer
;               02h ROM 8x14 character font pointer
;               03h ROM 8x8 double dot font pointer
;               04h ROM 8x8 double dot font (high 128 characters)
;               05h ROM alpha alternate (9 by 14) pointer (EGA,VGA)
;               06h ROM 8x16 font (MCGA, VGA)
;               07h ROM alternate 9x16 font (VGA only)
;
; Ausgabe: ES:BP = specified pointer
;          CX    = bytes/character
;          DL    = character rows on screen - 1
;
; AH=11h
; AL=30h
; BH=Welche Information soll geholt werden?
;    0=Inhalt des Interrupt-Vektors 1Fh
;    1=Inhalt des Interrupt-Vektors 43h
;    2=Adresse der 8x14-Zeichentabelle im ROM
;    3=Adresse der 8x8-Zeichentabelle im ROM
;    4=Adresse der zweiten Hälfte der 8x8-Zeichentabelle
;    5=Adresse der alternativen 9x14-Zeichentabelle im ROM
;    6=Adresse der 8x16-Zeichentabelle im ROM (nur VGA)
;    7=Adresse der alternativen 9x16-Zeichentabelle im ROM (nur VGA)
; Ausgabe: CX=Höhe der aktuellen Zeichenmatrix
;          DL=Anzahl Spalten pro Zeile-1
;          ES=Segmentadresse des abgefragten Pointers
;          BP=Offsetadresse des abgefragten Pointers
;
INT10_AH_11_AL_30:

%if DEBUG_INT10
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,10H
    CALL   Sende_DEBUG_INT_ok
    POP    BP
    POP    AX
%endif

    MOV    CX,BIOS_Segment
    MOV    ES,CX
    MOV    BP, INT_1F

    MOV    CX,0010H
    MOV    DL,18H

%if DEBUG_INT10
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,10H
    CALL   Sende_DEBUG_INT_Rueckgabe
    POP    BP
    POP    AX
%endif

    IRET    ;RETURN FROM INTERRUPT





; ****************************************
; * Funktion 12h: Videokonfiguration festlegen/abfragen (EGA/VGA)
; ****************************************
;
;
INT10_AH_12:

    CMP    BL,10H
    JZ     INT10_AH_12_BL_10


    CMP    BL,20H
    JZ     INT10_AH_12_BL_20


    CMP    BL,30H
    JZ     INT10_AH_12_BL_30




INT10_AH_12_ERROR:

%if ERROR_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,10H
    CALL   DEBUG_TRACE_UNSUPPORTED
    POP    BP
    POP    AX
%endif

    IRET    ;RETURN FROM INTERRUPT


; ------------------------------------
; - Unterfunktion AH = 12H, BL = 10H -
; ------------------------------------
; Diese Unterfunktion ermittelt die Konfiguration der EGA- und VGA-Karte.
;
; Eingabe: AH = 12H
;          BL = 10H

; Ausgabe: BH = video state
;                 00h color mode in effect (I/O port 3Dxh)
;                 01h mono mode in effect (I/O port 3Bxh)
;          BL = installed memory (00h = 64K, 01h = 128K, 02h = 192K, 03h = 256K)
;          CH = feature connector bits (see #00022)
;          CL = switch settings (see #00023,#00024)
;          AH destroyed (at least by Tseng ET4000 BIOS v8.00n)
;
; Ausgabe: BH=angeschlossener Monitor
;             0=Color- oder hochauflösender Monitor
;             1=monochromer Monitor
;          BL=Groesse EGA-RAM
;             0=64Kbyte
;             1=128 KByte
;             2=192 KByte
;             3=256 KByte
; ------------------------------------
;
INT10_AH_12_BL_10:

%if DEBUG_INT10
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,10H
    CALL   Sende_DEBUG_INT_ok
    POP    BP
    POP    AX
%endif

    MOV    BX,0003H
    MOV    CX,0009H

%if DEBUG_INT10
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,10H
    CALL   Sende_DEBUG_INT_Rueckgabe
    POP    BP
    POP    AX
%endif

    IRET    ;RETURN FROM INTERRUPT



; ------------------------------------
; - Unterfunktion AH = 12H, BL = 20H -
; ------------------------------------
; Da der BIOS-Interrupt 5h nicht für eine Hardcopy von mehr
; als 25 Zeilen geeignet ist, wird durch Aufruf dieser 
; Funktion eine alternative Routine erstellt, die eine
; Hardcopy von mehr als 25 Textzeilen unterstützt.
;
; select alternate print screen routine
; Notes: installs a PrtSc routine from the video card's BIOS to replace the
;        default PrtSc handler from the ROM BIOS, which usually does not
;        understand screen heights other than 25 lines
;        some adapters disable print-screen instead of enhancing it
;
; Eingabe: AH = 12H
;          BL = 20H

; Ausgabe: 
; ------------------------------------
;
INT10_AH_12_BL_20:

%if DEBUG_INT10
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,10H
    CALL   Sende_DEBUG_INT_ok
    POP    BP
    POP    AX
%endif

    MOV    CX,00FFH

%if DEBUG_INT10
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,10H
    CALL   Sende_DEBUG_INT_Rueckgabe
    POP    BP
    POP    AX
%endif

    IRET    ;RETURN FROM INTERRUPT




; ------------------------------------
; - Unterfunktion AH = 12H, BL = 30H -
; ------------------------------------
; Legt die Anzahl der Bildschirmzeilen (Scan-Lines) im Grafikmodus fest.
; VIDEO - ALTERNATE FUNCTION SELECT (VGA) - SELECT VERTICAL RESOLUTION
;
; Eingabe: AH = 12H
;          BL = 30H
;          AL=Anzahl Scan-Lines
;             0=200
;             1=350
;             2=400 (nur VGA)
;
; Ausgabe: AL = 12h if function supported
; ------------------------------------
;
INT10_AH_12_BL_30:

%if DEBUG_INT10
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,10H
    CALL   Sende_DEBUG_INT_ok
    POP    BP
    POP    AX
%endif

    MOV    AX,1212H
    MOV    CX,00FFH

%if DEBUG_INT10
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,10H
    CALL   Sende_DEBUG_INT_Rueckgabe
    POP    BP
    POP    AX
%endif

    IRET    ;RETURN FROM INTERRUPT





; ********************************************************
; * INT 10 - AH = FEh VIDEO (TopView) - GET VIDEO BUFFER
; ********************************************************
;
; Eingabe: AH = FEh VIDEO (TopView) - GET VIDEO BUFFER
;          ES:DI = segment:offset of assumed video buffer
;
; Ausgabe: ES:DI = segment:offset of actual video buffe
; ****************************************
INT10_AH_FE:


%if DEBUG_INT10
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,10H
    CALL   Sende_DEBUG_INT_ok
    POP    BP
    POP    AX
%endif


    MOV    AX,0B800H   ; ES = B800H
    MOV    ES,AX
    MOV    DI,0000H    ; DI = 0000H


%if DEBUG_INT10
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,10H
    CALL   Sende_DEBUG_INT_Rueckgabe
    POP    BP
    POP    AX
%endif

    IRET    ;RETURN FROM INTERRUPT






; ****************************************
; * VIDEO - DISPLAY COMBINATION (AH = 1AH)
; ****************************************
; INT 10 - VIDEO - DISPLAY COMBINATION (PS,VGA/MCGA)
;
; Eingabe: AH = 1Ah
;
;          AL = 00h read display combination code
; Ausgabe: BL = active display code (see below)
;          BH = alternate display code
;
;          AL = 01h set display combination code
;          BL = active display code (see below)
;          BH = alternate display code
; Ausgabe: AL = 1Ah if function was supported
;
; Values for display combination code:
;   00h no display
;   01h monochrome adapter w/ monochrome display
;   02h CGA w/ color display
;   03h reserved
;   04h EGA w/ color display
;   05h EGA w/ monochrome display
;   06h PGA w/ color display
;   07h VGA w/ monochrome analog display
;   08h VGA w/ color analog display
;   09h reserved
;   0Ah MCGA w/ digital color display
;   0Bh MCGA w/ monochrome analog display
;   0Ch MCGA w/ color analog display
;   FFh unknown display type
;
; ****************************************
INT10_AH_1A:


%if ERROR_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,10H
    CALL   DEBUG_TRACE_UNSUPPORTED
    POP    BP
    POP    AX
%endif



    IRET    ;RETURN FROM INTERRUPT







; -----------------------------------------------------------------





; ******************************
;  i-meic Basisroutine CLEAR_VIDEO_RAM
;
; Eingabe: keine
;
; Ausgabe: keine
;
; ******************************

CLEAR_VIDEO_RAM:

    PUSH   AX
    PUSH   BX
    PUSH   CX
    PUSH   DX
    PUSH   ES

    MOV    AX, 0B800H
    MOV    ES, AX

    MOV    BX, 0

    MOV    CX, 2000
    MOV    AL, ' ';
    MOV    AH, 07H

CLEAR_VIDEO_LOOP:         ;LOOP LABLE
    MOV    [es:BX], AL       ;LOAD BYTE
                             ;WRITE BYTE
    INC    BX                 ;INC BX

    MOV    [es:BX], AH       ;LOAD BYTE
                             ;WRITE BYTE
    INC    BX                 ;INC BX

    LOOP   CLEAR_VIDEO_LOOP ;LOOP UNTIL DONE


    POP    ES
    POP    DX
    POP    CX
    POP    BX
    POP    AX


    RET














; ******************************
;  i-meic Basisroutine VI_SysTick_ein
;
; Eingabe: keine
;
; Ausgabe: keine
;
; ******************************

VI_SysTick_ein:

    MOV    AL,IORQ_VIDEO_SysTick
    OUT    AUSGANG,AL

    MOV    AL,1
    OUT    AUSGANG,AL  ; 

    RET





; ******************************
;  i-meic Basisroutine VI_SysTick_aus
;
; Eingabe: keine
;
; Ausgabe: keine
;
; ******************************

VI_SysTick_aus:

    MOV    AL,IORQ_VIDEO_SysTick
    OUT    AUSGANG,AL

    MOV    AL,0
    OUT    AUSGANG,AL  ; 

    RET





; ******************************
;  i-meic Basisroutine VIDEO_PARAM_SEND
;
; Eingabe: AL Code der Routine
;          BL 1.Parameter
;          BH 2.Parameter

; Ausgabe: keine
;
; ******************************

VIDEO_PARAM_SEND:

    PUSH   AX

    MOV    AL,IORQ_VIDEO_SEND
    OUT    AUSGANG,AL

    POP    AX

    OUT    AUSGANG,AL  ; Code der Routine

    MOV    AL,BL
    OUT    AUSGANG,AL  ; 1.Parameter

    MOV    AL,BH
    OUT    AUSGANG,AL  ; 2.Parameter

    RET







; ******************************
;  i-meic Basisroutine VIDEO_PARAM_RESV
;
; Eingabe: AL Code der Routine
;
; AUSGABE: BL 1.Parameter
;          BH 2.Parameter
;
; ******************************

VIDEO_PARAM_RESV:

    PUSH   AX

    MOV    AL,IORQ_VIDEO_RESV
    OUT    AUSGANG,AL

    POP    AX

    OUT    AUSGANG,AL  ; Code der Routine


    IN     AL,AUSGANG  ; 1.Parameter -> BL
    MOV    BL,AL

    IN     AL,AUSGANG  ; 2.Parameter -> BH
    MOV    BH,AL

    RET





; ###################################################






INT10_VIDEO_TSA:

    PUSH   AX
    PUSH   BX
    PUSH   CX
    PUSH   DX
    PUSH   ES
    PUSH   DS
    PUSH   BP

; Adresse Haupt-Video-RAM
    MOV    AX, 0B800H
    MOV    ES, AX
; Adresse Kopie des Video-RAM
    MOV    AX, 0E800H
    MOV    DS, AX


    ; Zeiger auf aktuelles Byte (0..3999)
    MOV    BX, 0
    ; DL=Sektor_Abschnitt (0..199)
    MOV    DL, 0


INT10_VIDEO_TSA_02:

    MOV    CX, 20

    ; Schalter fuer Ungleich
    MOV    DH, 0   

    PUSH   BX            ; BX retten

INT10_VIDEO_TSA_LOOP:         ;LOOP LABLE
    MOV    AL, [es:BX]       ;LOAD BYTE
    MOV    AH, [ds:BX]       ;LOAD BYTE
    CMP    AL,AH
    JZ     INT10_VIDEO_TSA_03

    MOV    DH, 1         ; VIDEO-RAM-Inhalt in diesem
                         ; Sektor-Abschnitt ist ungleich

INT10_VIDEO_TSA_03:
    INC    BX                   ;INC BX
    LOOP   INT10_VIDEO_TSA_LOOP ;LOOP UNTIL DONE


; Soll der Sektor-Abschnitt uebertragen werden?
    POP    AX           ; BX vom Anfang des Sektor-Abschnitt
                        ; wird in AX geladen

    CMP    DH,0
    JZ     INT10_VIDEO_TSA_04

    CALL   COPY_VIDEO_TSA

INT10_VIDEO_TSA_04:


    INC    DL
    CMP    DL,200

    JNZ    INT10_VIDEO_TSA_02


    POP    BP
    POP    DS
    POP    ES
    POP    DX
    POP    CX
    POP    BX
    POP    AX


    RET






; ****************************************
; COPY_VIDEO_TSA
; Uebergabe:
;  AX=Startadresse der zu uebertragenden 20 Bytes
;  DL=Sektor_Abschnitt (0..199)
; ****************************************
COPY_VIDEO_TSA:

    PUSH   AX
    PUSH   BX
    PUSH   CX
    PUSH   DX

; lade BX mit der Adresse des aktuellen Sektor_Abschnittes
    MOV    BX, AX


; Senden des Sektor-Abschnitts an die
; CONSOLE64

    MOV    AL,IORQ_VIDEO_SA_Teil
    OUT    AUSGANG,AL

; Senden SA-Nummer
    MOV    AL,DL
    OUT    AUSGANG,AL

    MOV    CX, 20

COPY_VIDEO_TSA_LOOP:         ;LOOP LABLE
    MOV    AL, [es:BX]       ;LOAD BYTE
    MOV    [ds:BX],AL        ;LOAD BYTE
    OUT    AUSGANG,AL
    INC    BX                ;INC BX
    LOOP   COPY_VIDEO_TSA_LOOP ;LOOP UNTIL DONE


    POP    DX
    POP    CX
    POP    BX
    POP    AX

    RET




; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx






; ***************************************************
; BYTE_TO_CONOUT

; Anzeige eines Bytes auf der CONSOLE (INT10 FKT:0E)

; Eingabe: AL=auszugebendes Byte
; 
; Ausgabe: keine
;
; ***************************************************

HEX  DB  '0123456789ABCDEF'

BYTE_TO_CONOUT:

    PUSH  AX
    PUSH  BX
    PUSH  CX
    PUSH  DS

    MOV   BX, CS
    MOV   DS, BX

    MOV   AH, AL            ; kopieren von AL (das Byte)
    SHR   AL, 1
    SHR   AL, 1
    SHR   AL, 1
    SHR   AL, 1

    MOV   CX, HEX
    MOV   BX, 0
    MOV   BL, AL
    ADD   BX, CX
    MOV   AL, [ds:BX]

    PUSH  AX
    PUSH  BX
    PUSH  CX

    MOV   BX, 0007H
    MOV   AH, 0EH
    INT   10H

    POP   CX
    POP   BX
    POP   AX

    AND   AH, 0FH
    MOV   BX, 0
    MOV   BL, AH
    ADD   BX, CX
    MOV   AL, [ds:BX]

    MOV   BX, 0007H
    MOV   AH, 0EH
    INT   10H

    POP   DS
    POP   CX
    POP   BX
    POP   AX

    RET







; ***************************************************
; WORD_TO_CONOUT

; Anzeige eines Words auf der CONSOLE (INT10 FKT:0E)

; Eingabe: AX=auszugebendes Word
; 
; Ausgabe: keine
;
; ***************************************************

WORD_TO_CONOUT:

    PUSH  AX
    MOV   AL,AH
    CALL  BYTE_TO_CONOUT ; Anzeige AH

    POP   AX
    CALL  BYTE_TO_CONOUT ; Anzeige AL

    RET





; ***************************************************
; TEXT_TO_CONOUT

; Ausgabe eines Textes an die CONSOLE (INT10 FKT:0E)
; Ende des Textes ist 0!
;
; Eingabe: BX=OFFST auszugebender Text
; 
; Ausgabe: keine
;
; ***************************************************
TEXT_TO_CONOUT:

    MOV   AL,[cs:BX]
    CMP   AL, 0
    JZ    TEXT_TO_CONOUT_ENDE

    PUSH   BX
    MOV    AH, 0EH
    MOV    BX, 0007H
    INT    10H
    POP    BX
    INC    BX
    JMP    TEXT_TO_CONOUT

TEXT_TO_CONOUT_ENDE:

    RET



; ***************************************************
; FDD_TO_CONOUT
;
; Eingabe: keine
; 
; Ausgabe: keine
;
; ***************************************************

TEXT_FDD_01  DB  'Anzahl FDD=', 0
TEXT_FDD_02  DB  'H',0DH, 0AH, 0

FDD_TO_CONOUT:

    MOV   BX, TEXT_FDD_01
    CALL  TEXT_TO_CONOUT

    MOV   AL,[ds:DISK_FDD_CNT]
    CALL  BYTE_TO_CONOUT

    MOV   BX, TEXT_FDD_02
    CALL  TEXT_TO_CONOUT

    RET






; ***************************************************
; HDD_TO_CONOUT
;
; Eingabe: keine
; 
; Ausgabe: keine
;
; ***************************************************

TEXT_HDD_01  DB  'Anzahl HDD=', 0
TEXT_HDD_02  DB  'H',0DH, 0AH, 0

HDD_TO_CONOUT:

    MOV   BX, TEXT_HDD_01
    CALL  TEXT_TO_CONOUT

    MOV   AL,[ds:DISK_HDD_CNT]
    CALL  BYTE_TO_CONOUT

    MOV   BX, TEXT_HDD_02
    CALL  TEXT_TO_CONOUT

    RET
