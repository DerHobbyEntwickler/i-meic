

; ******************************
; ***   INT 18 -  ROM-Basic  ***
;
; Hinweis: Das ROM-Basic ist im i-meic nicht implementiert.
;          Der Interrupt INT_18 wird fuer zahlreiche
;          Hilfsprogramme genutzt.
;
; ******************************



; ********************************
; *  Speichervariablen ROM-Basic *
; ********************************







INT_18:    ;ROM-Basic (INT 18)



    CMP    AX,8080H
    JNE    INT_18_8081
    JMP    VGA_BIOS_OFF         ; 

INT_18_8081:
    CMP    AX,8081H
    JNE    INT_18_8082
    JMP    VGA_BIOS_ON          ; 

INT_18_8082:
    CMP    AX,8082H
    JNE    INT_18_8083
    JMP    MOUSE_BIOS_ON        ; 

INT_18_8083:
    CMP    AX,8083H
    JNE    INT_18_8084
    JMP    MOUSE_BIOS_OFF       ; 

INT_18_8084:
    CMP    AX,8084H
    JNE    INT_18_8085
    JMP    READ_BIOS            ; 

INT_18_8085:
    CMP    AX,8085H
    JNE    INT_18_8086
    JMP    WRITE_BIOS           ; 

INT_18_8086:

    CMP    AX,8086H
    JNE    INT_18_8087
    JMP    READ_DEVLST          ; 

INT_18_8087:




%if ERROR_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,18H
    CALL   DEBUG_TRACE_UNSUPPORTED
    POP    BP
    POP    AX
%endif

    IRET    ;RETURN FROM INTERRUPT




; *******************************************
; * INT 18 - ROM-Basic /  Funktion AX=8080H *
; * VGA-BIOS-ON - Umschalten auf VGA-BIOS   *
; *               auf E000:0000H            *
; *******************************************
VGA_BIOS_ON:


    PUSH   AX
    PUSH   BX
    PUSH   CX
    PUSH   DX
    PUSH   ES
    PUSH   DS




    MOV    CX, INT10_DISPATCH  ; CX = OFFSET von INT10_DISPATCH
    MOV    DX, BIOS_Segment         ; DX = Segment von INT10

    MOV    AX,0000H
    MOV    ES,AX
    MOV    BX,10H*4
    MOV    word [es:BX], CX     ; CX = OFFSET von INT10
    ADD    BX,2
    MOV    word [es:BX], DX     ; DX = Segment von INT10
 

   


    ; Interrupt-bezogene Verarbeitung, 

    MOV    AX, CS    ; 
    MOV    DS, AX

  
    MOV    AX, TRUE
    MOV    [ds:INT02_VIDEO_TSA_SWITCH], AX 


   

    POP    DS
    POP    ES
    POP    DX
    POP    CX
    POP    BX
    POP    AX

%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,18H
    CALL   DEBUG_TRACE_ENTRY
    POP    BP
    POP    AX
%endif

    IRET    ;RETURN FROM INTERRUPT




; *******************************************
; * INT 18 - ROM-Basic /  Funktion AX=8081H *
; * VGA-BIOS-OFF - Rueckschaten auf BIOS    *
; *                INT10H auf F800:INT10    *
; *******************************************
VGA_BIOS_OFF:


    PUSH   AX
    PUSH   BX
    PUSH   CX
    PUSH   DX
    PUSH   ES
    PUSH   DS


    MOV    CX, INT_10  ; CX = OFFSET von INT10
    MOV    DX, BIOS_Segment         ; DX = Segment von INT10

    MOV    AX,0000H
    MOV    ES,AX
    MOV    BX,10H*4
    MOV    word [es:BX], CX     ; CX = OFFSET von INT10
    ADD    BX,2
    MOV    word [es:BX], DX     ; DX = Segment von INT10




    ; Interrupt-bezogene Verarbeitung, 

    MOV    AX, CS    ; 
    MOV    DS, AX

  
    MOV    AX, FALSE
    MOV    [ds:INT02_VIDEO_TSA_SWITCH], AX 


    POP    DS
    POP    ES
    POP    DX
    POP    CX
    POP    BX
    POP    AX

%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,18H
    CALL   DEBUG_TRACE_ENTRY
    POP    BP
    POP    AX
%endif

    IRET    ;RETURN FROM INTERRUPT






; ********************************************
; * INT 18 - ROM-Basic /  Funktion AX=8082H  *
; * MOUSE_BIOS_ON - Umschalten auf Maus-BIOS *
; *                INT33H auf F800:INT13     *
; ********************************************
MOUSE_BIOS_ON:

    PUSH   AX
    PUSH   BX
    PUSH   CX
    PUSH   DX
    PUSH   ES


    MOV    CX, INT_33  ; CX = OFFSET von INT33H
    MOV    DX, BIOS_Segment         ; DX = Segment von INT33H

    MOV    AX,0000H
    MOV    ES,AX
    MOV    BX,33H*4
    MOV    word [es:BX], CX     ; CX = OFFSET von INT33H
    ADD    BX,2
    MOV    word [es:BX], DX     ; DX = Segment von INT33H


    POP    ES
    POP    DX
    POP    CX
    POP    BX
    POP    AX


%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,18H
    CALL   DEBUG_TRACE_ENTRY
    POP    BP
    POP    AX
%endif

    IRET    ;RETURN FROM INTERRUPT





; ********************************************
; * INT 18 - ROM-Basic /  Funktion AX=8083H  *
; * MOUSE_BIOS_OFF - Abschalten des Maus-BIOS *
; *                INT33H auf F800:INT13     *
; ********************************************
MOUSE_BIOS_OFF:

; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; derzeit nicht implementiert


    IRET    ;RETURN FROM INTERRUPT




; *********************************************
; * INT 18 - ROM-Basic /  Funktion AX=8084H   *
; * READ_BIOS - Read BIOS-Data to BIOS-Vector *
; *********************************************
READ_BIOS:

    PUSH   AX


    MOV    BX, BIOS_VECTOR_TABLE 

    ; READ BIOS (10 Byte, 0..9)

    MOV    AL, IORQ_READ_BIOS
    OUT    AUSGANG,AL


    MOV    CX, 10             ; Laenge von 10 Byte


INT18_READ_IN_LOOP:           ;LOOP LABLE
    IN     AL, AUSGANG        ;READ BYTE
    MOV    [cs:BX], AL        ;STORE BYTE
    INC    BX                 ;INC BX
    LOOP   INT18_READ_IN_LOOP ;LOOP UNTIL DONE


    POP    AX


    MOV    BX, BIOS_Segment                    ; Segment BIOS_VECTOR_TABLE
    MOV    CX, BIOS_VECTOR_TABLE  ; Offset  BIOS_VECTOR_TABLE


%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,18H
    CALL   DEBUG_TRACE_ENTRY
    POP    BP
    POP    AX
%endif


    IRET    ;RETURN FROM INTERRUPT






; ***********************************************
; * INT 18 - ROM-Basic /  Funktion AX=8085H     *
; * WRITE_BIOS - Write BIOS-Vector to BIOS-Data *
; ***********************************************
WRITE_BIOS:


    PUSH   AX


    MOV    BX, BIOS_VECTOR_TABLE 

    ; READ BIOS (10 Byte, 0..9)

    MOV    AL, IORQ_WRITE_BIOS
    OUT    AUSGANG,AL


    MOV    CX, 10             ; Laenge von 10 Byte


INT18_WRITE_IN_LOOP:           ;LOOP LABLE
    MOV    AL,[cs:BX]          ;READ BYTE
    OUT    AUSGANG,AL          ;READ BYTE
    INC    BX                 ;INC BX
    LOOP   INT18_WRITE_IN_LOOP ;LOOP UNTIL DONE


    POP    AX


%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,18H
    CALL   DEBUG_TRACE_ENTRY
    POP    BP
    POP    AX
%endif


    IRET    ;RETURN FROM INTERRUPT








; *********************************************
; * INT 18 - ROM-Basic /  Funktion AX=8086H   *
; * READ_DEVLST - Read DeviceList             *
; *********************************************
READ_DEVLST:

    PUSH   AX


    MOV    BX, DEVICE_LIST 

    ; READ Device-List (10 Byte, 0..9)

    MOV    AL, IORQ_READ_DevList
    OUT    AUSGANG,AL


    MOV    CX, 42             ; Laenge von 42 Byte (0..41)


INT18_DEVLST_IN_LOOP:         ;LOOP LABLE
    IN     AL, AUSGANG        ;READ BYTE
    MOV    [cs:BX], AL        ;STORE BYTE
    INC    BX                 ;INC BX
    LOOP   INT18_DEVLST_IN_LOOP ;LOOP UNTIL DONE


    POP    AX


    MOV    BX, BIOS_Segment                    ; Segment DEVICE_LIST
    MOV    CX, DEVICE_LIST        ; Offset  DEVICE_LIST


%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,18H
    CALL   DEBUG_TRACE_ENTRY
    POP    BP
    POP    AX
%endif


    IRET    ;RETURN FROM INTERRUPT
