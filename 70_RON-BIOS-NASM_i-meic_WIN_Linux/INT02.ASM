; *******************************************
; * INT 02 - NMI SysTick Hardware-Interrupt * 
; *******************************************
;
; Beschreibung
; ============
; Alle 55mS (18 mal pro Sekunde) wird durch den NMI-Hardware-Interrupt
; der INT02 ausgeloest.
; Die Routine wird fuer 3 Ereignisse genutzt: 
; 1. 



; ********************************
; *** Variablen fuer den INT02 ***
; ********************************
;

INT02_VIDEO_TSA_SWITCH  DW   FALSE

INT02_VIDEO_TSA_cnt     DW  0


; ************************************
; *** Interrupt-Routine fuer INT02 ***
; ************************************
;
INT_02: ;Nonmaskable Interrupt

    PUSHF
    PUSH AX           ; Sichern der Register



    MOV    AX, [cs:INT02_VIDEO_TSA_cnt]
    ADD    AX, 1 
    MOV    [cs:INT02_VIDEO_TSA_cnt], AX



    ; Aufruf MS-DOS TIMER Register INC
    ;
    INT    08H       ; 



    POP AX
    POPF

    IRET    ;RETURN FROM INTERRUPT





; ====================================================



; ******************************
;  i-meic Basisroutine 
;
; startet den Counter fuer den NMI-Port,
; der den SysTick ausloest, INT02 -> INT08 -> INT1A
;
; Eingabe: keine
;
; Ausgabe: keine
;
; ******************************

Start_SysTick:

    MOV    AL,IORQ_START_SysTick
    OUT    AUSGANG,AL

    RET
