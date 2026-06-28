; ============================================================================
;  DEBUG
; ============================================================================

%if DEBUG_MSG

; Uebergabe der Registerinhalte bei 
; Eintritt in die Interrupt-Funktion
DEBUG_TRACE_ENTRY:
; Setzen der ART
    MOV   AL,01H
    CALL  DEBUG_SEND_TELEMETRY

    RET



DEBUG_TRACE_UNSUPPORTED:
; Setzen der ART
    MOV   AL,02H
    CALL  DEBUG_SEND_TELEMETRY

    RET



DEBUG_TRACE_RETURN:
; Setzen der ART
    MOV   AL,03H
    CALL  DEBUG_SEND_TELEMETRY

    RET



DEBUG_TRACE_RETURN_ERROR:
; Setzen der ART
    MOV   AL,05H
    CALL  DEBUG_SEND_TELEMETRY

    RET







; Senden von AR + 18 Byte an Serial
DEBUG_SEND_TELEMETRY:

    PUSH  AX

; Starten der IORQ_DEBUG-Uebertragung
    MOV   AL,IORQ_DEBUG
    OUT   AUSGANG,AL

    POP   AX

; DEBUG_Zellen[00] -> AR=01
    OUT   AUSGANG,AL

; DEBUG_Zellen[01] -> INT-Nummer
    MOV   AL,AH
    OUT   AUSGANG,AL

; DEBUG_Zellen[02..03] -> AH+AL
; Sende AH
    MOV   AX,BP
    MOV   AL,AH
    OUT   AUSGANG,AL
; Sende AL
    MOV   AX,BP
    OUT   AUSGANG,AL

; DEBUG_Zellen[04..05] -> BH+BL
    MOV   AL,BH
    OUT   AUSGANG,AL
    MOV   AL,BL
    OUT   AUSGANG,AL

; DEBUG_Zellen[06..07] -> CH+CL
    MOV   AL,CH
    OUT   AUSGANG,AL
    MOV   AL,CL
    OUT   AUSGANG,AL

; DEBUG_Zellen[08..09] -> DH+DL
    MOV   AL,DH
    OUT   AUSGANG,AL
    MOV   AL,DL
    OUT   AUSGANG,AL

; DEBUG_Zellen[10] -> FLAG-Byte
    LAHF
    MOV   AL,AH
    OUT   AUSGANG,AL




; DEBUG_Zellen[11..12] -> BP
    MOV   BP,SP
    MOV   AX,word [ss:BP+4]  ; 
; Sende AH
    PUSH  AX
    MOV   AL,AH
    OUT   AUSGANG,AL
; Sende AL
    POP   AX
    OUT   AUSGANG,AL


; DEBUG_Zellen[13..14] -> SI
; Sende AH
    MOV   AX,SI
    MOV   AL,AH
    OUT   AUSGANG,AL
; Sende AL
    MOV   AX,SI
    OUT   AUSGANG,AL


; DEBUG_Zellen[15..16] -> DI
; Sende AH
    MOV   AX,DI
    MOV   AL,AH
    OUT   AUSGANG,AL
; Sende AL
    MOV   AX,DI
    OUT   AUSGANG,AL


; DEBUG_Zellen[17..18] -> ES
; Sende AH
    MOV   AX,ES
    MOV   AL,AH
    OUT   AUSGANG,AL
; Sende AL
    MOV   AX,ES
    OUT   AUSGANG,AL


    RET









; 4 Zeilen ab ES:BX
;
; Senden von AR + 10 Byte an Serial
; ES:BX=Adresse des Lesepuffers 
Sende_DEBUG_Speicher_ES_BX:

    PUSH   AX
    PUSH   BX
    PUSH   CX
    CALL   Sende_DEBUG_Speicher
    CALL   Sende_DEBUG_Speicher
    CALL   Sende_DEBUG_Speicher
    CALL   Sende_DEBUG_Speicher
    POP    CX
    POP    BX
    POP    AX

    RET







; Senden von AR + 18 Byte an Serial
; ES:BX=Adresse des Lesepuffers
Sende_DEBUG_Speicher:

; Starten der IORQ_DEBUG-Uebertragung
    MOV   AL,IORQ_DEBUG
    OUT   AUSGANG,AL

; DEBUG_Zellen[00] -> AR=04
    MOV   AL, 04H
    OUT   AUSGANG,AL

; DEBUG_Zellen[01] -> Adresse BH
    MOV   AL,BH
    OUT   AUSGANG,AL

; DEBUG_Zellen[02] -> Adresse BL
    MOV   AL,BL
    OUT   AUSGANG,AL



    MOV   CX,16


Sende_DEBUG_Speicher_LOOP:
    MOV   AL,[es:BX]                 ;Lese BYTE
    OUT   AUSGANG,AL
    INC   BX                         ;INC BX
    LOOP  Sende_DEBUG_Speicher_LOOP  ;LOOP UNTIL DONE


    RET




%else

DEBUG_TRACE_ENTRY:
    RET
DEBUG_TRACE_UNSUPPORTED:
    RET
DEBUG_TRACE_RETURN:
    RET
DEBUG_TRACE_RETURN_ERROR:
    RET


%endif




