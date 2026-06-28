

; **************************************
; ***  INT 08 - SysTick - Interrupt  ***
; **************************************
;
INT_08:

    PUSHF
    PUSH   AX
    PUSH   BX
    PUSH   DS

    MOV    BX,0040H    ; BIOS DATA AREA
    MOV    DS,BX       ; SET DATA SEGMENT


    MOV    BX,006CH    ; OFFSET 6CH = Zähler Low Word
    ADD    word [ds:BX],1   ; STORE Zähler Low Word

    MOV    BX,006EH    ; OFFSET 6EH = Zähler High Word
    ADC    word [ds:BX],0  ; STORE Zähler High Word


; Der 24-Stunden-Rollover (ca. 1.573.040 Ticks = `0x180C0`) wird **nicht** überprüft. 
; Das IBM-BIOS setzt bei Overflow das Rollover-Byte in BDA:0470H. Ohne diese Logik liefert `INT 1A AH=00H`
; im Feld AL (Overflow-Flag) immer `0x00`, auch wenn mehr als 24h vergangen sind. 
; Betriebssysteme, die dies auswerten, ermitteln damit eine falsche Uhrzeit.



;----------------------------------------------------------------------------;

; Call INT 1CH user vector
;
INT_08_INT1C:

    INT    1CH       ; call user timer hook

;----------------------------------------------------------------------------;


    POP    DS
    POP    BX
    POP    AX
    POPF


    IRET    ;RETURN FROM INTERRUPT
