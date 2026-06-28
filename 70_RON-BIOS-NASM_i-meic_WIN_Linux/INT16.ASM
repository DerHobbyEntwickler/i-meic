
; *************************************
; Interrupt 16H: Tastatur-Zugriff
;
; AH       Description
; 00h   Read Character
; 01h   Read Input Status
; 02h   Read Keyboard Shift Status
; 05h   Store Keystroke in Keyboard Buffer
; 10h   Read Character Extended
; 11h   Read Input Status Extended
; 12h   Read Keyboard Shift Status Extended 
;
; *************************************

INT_16: ;Keyboard



    CMP    AH,00H
    JZ     Read_Character

    CMP    AH,01H
    JZ     Read_Input_Status

    CMP    AH,02H
    JZ     Read_Keyboard_Shift_Status



; Interrupt-Funktion nicht gefunden

%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,16H
    CALL   DEBUG_TRACE_UNSUPPORTED
    POP    BP
    POP    AX
%endif


    IRET



; *******************************
; Funktion 00h: Tastaturcode aus Puffer lesen
; (Veraltete Funktion, ersetzt durch Funktion 10h)
;
; Eingabe: AH=00h 
; Ausgabe: AX=Tastaturcode (s.u.)
;
; DerTastaturcode besteht aus 2 Byte in AL und AH. AL enthaelt den Zeichencode.
; Das ist der ASCII-Code des Zeichens. In AH befindet sich der Scancode der Tastatur.
; Dieser ist abhaeangig von der Tastatur.
; Falls AL=0 ist, enthaelt AH den erweiterten Tastaturcode einer Sondertaste.
; Nach Aufruf dieser Funktion ist das Zeichen aus dem Puffer geloescht.
; Befindet sich kein Zeichen im Puffer, wartet die Funktion so lange, 
; bist ein Zeichen eingegeben wird. 
; Der Rechner ist fuer diese Zeit fuer andere Aufgaben blockiert!
; Ist das nicht erwuenscht, sollte man besser mit der nachfolgenden Funktion
; vorher prueufen, ob ein Zeichen vorhanden ist.
; Achtung: Nicht alle Sonder-Tasten /-Kombinationen werden unterstuetzt, daher besser
; die neuere Funktion 10h zur Tastaturabfrage verwenden!
; *******************************
; CONIN
Read_Character:




Read_Character_02:



; CONST lesen

    MOV    AL,IORQ_CONST
    OUT    AUSGANG,AL


    IN     AL,AUSGANG




; ist ein Eingabewert vorhanden, so ist 
; Register AL groesser 0
    CMP    AL,0

    JZ     Read_Character_02




; CONIN lesen

    MOV    AL,IORQ_CONIN
    OUT    AUSGANG,AL

    IN     AL,AUSGANG
    MOV    AH, AL

    IN     AL,AUSGANG





    IRET    ;RETURN FROM INTERRUPT



; *******************************************
; Funktion 01h: Tastaturpuffer pruefen
; (Veraltete Funktion, ersetzt durch Funktion 11h)
; Eingabe: AH=01h 
; Ausgabe: Zero-Flag zeigt Pufferstatus
; an (s.u.).
; AX=Tastaturcode
; Ist das ZF gesetzt, befindet sich kein Zeichen im Puffer. 
; AX ist dann ungueltig.
; Ist ZF nicht gesetzt, gilt fuer AX das zu Funktion 00h gesagte.
; Das Zeichen wird nicht aus dem Puffer geloescht.
; *******************************************



Read_Input_Status:




    MOV    AX, [cs:INT02_VIDEO_TSA_SWITCH]
    CMP    AX, TRUE
    JNZ    CONST_D



    MOV    AX, [cs:INT02_VIDEO_TSA_cnt]
    CMP    AX, 8
    JC     CONST_D


    MOV    AX, 0
    MOV    [cs:INT02_VIDEO_TSA_cnt], AX


    CALL   INT10_VIDEO_TSA





CONST_D:

; CONST lesen

    MOV    AL,IORQ_CONST
    OUT    AUSGANG,AL

    IN     AL,AUSGANG

    JMP    CONST_C


CONST_B:
    MOV    AL,0



CONST_C:


; ist ein Eingabewert in AL vorhanden, so ist 
; Register AL groesser 0 und das ZF wird geloescht
    CMP    AL,0

;    POP    DS

    JMP    END_WITH_ZERO_FLAG



; *******************************************
; Funktion 02h: Tastaturstatus lesen
; (Welche Hilfs-Taste ist gedrueckt?)
;
; Eingabe: AH=02h 
; Ausgabe: AL=Tastaturstatus (s.u.)
;
; Tastaturstatus:
; Bit-Nr. Bedeutung:
; 0 rechte Shifttaste gedrueckt
; 1 linke Shifttaste gedrueckt
; 2 Strg-Taste gedrueckt
; 3 Alt-Taste gedrueckt
; Bit-Nr. Bedeutung:
; 4 Scroll-Lock aktiv
; 5 Num-Lock aktiv
; 6 Caps-Lock aktiv
; 7 Einf-Taste gedrueckt
; *******************************
Read_Keyboard_Shift_Status:


;    PUSH   AX
;    PUSH   BP
;    MOV    BP,AX
;    MOV    AH,16H
;    CALL   Sende_DEBUG_INT_ok
;    POP    BP
;    POP    AX


    MOV    AX,0200H

    IRET    ;RETURN FROM INTERRUPT





;******************************************
;  IRET mit Uebertragung des ZERO-Flags
;******************************************
END_WITH_ZERO_FLAG:
    PUSH   AX               ; STORE AX
    PUSH   BX

    PUSHF                   ; STORE FLAGS
    POP   BX                ; GET BX = FLAGS

    PUSH  BP                ; STORE BP
    MOV   BP, SP            ; Copy SP to BP for use as index
    ADD   BP, 10            ; Offset 16, (Flags, CS, IP, AX, BX)
    MOV   AX, [BP]
AND   AX, 1111111110111111B ; setze ZERO-Flag=0
AND   BX, 0000000001000000B ; nur ZERO-Flag veraendern
    OR    AX, BX
    MOV   [BP], AX          ; SET CF AX
    POP   BP                ; RESTORE BASE POINTER

    POP   BX
    POP   AX                ; RESTORE AX

    IRET
