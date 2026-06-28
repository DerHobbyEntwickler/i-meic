
; *************************************
; ***  INT 33H - Mouse - Interrupt  ***
; *************************************
;

; *************************************
; Der Maus-Treiber-Interrupt (INT 33H)
;
; AX       Description
; 0000H   Maus INIT (AX = 00H)
; 0001H   Display_Pointer
; 0002H   Hide_Pointer
; 0003H   Query_Position_and_Buttons
;
; *************************************

INT_33: ; Mouse



    CMP    AX,0000H
    JZ     MouseInit

    CMP    AX,0001H
    JZ     ShowMouse

    CMP    AX,0002H
    JZ     HideMouse

    CMP    AX,0003H
    JZ     ReadMouse 




; Interrupt-Funktion nicht gefunden

%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,33H
    CALL   DEBUG_TRACE_UNSUPPORTED
    POP    BP
    POP    AX
%endif


    IRET



; *******************************
; Funktion 0000H: Init und Reset des Maustreibers
;
; Eingabe: AX=0000H 
;
; Ausgabe: AX=0000H -> kein Treiber installiert
;          AX=FFFFH -> Treiber vorhanden
; BX: Anzahl der Maustasten
;          BX=FFFFH 2 Maustasten
;          BX=0000H Maus besitzt keine 2 Tasten
;          BX=0003H Mouse System / Logitech Maus
;
; Mit diesem Aufruf wird der MS-Maus-Treiber initialisiert.
;
; Info: Resets the mouse.  Use this function to determine if mouse
;       support is present.  It performs a hardware and software reset
;       (see INT 33H 0021H for a way to performs just a software reset).
;
;       For text-mode applications, this function does the following:
;
;       • Moves the mouse pointer to the center of the screen
;       • Hides the pointer (use INT 33H 0001H to display it).
;
; *******************************
; 
MouseInit:

%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,33H
    CALL   DEBUG_TRACE_ENTRY
    POP    BP
    POP    AX
%endif


    MOV    AL,IORQ_MOUSE
    OUT    AUSGANG,AL

    MOV    AL,'i'   ; 'i' = MouseInit
    OUT    AUSGANG,AL


    MOV    AX,0FFFFH
    MOV    BX,0FFFFH


%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,33H
    CALL   DEBUG_TRACE_RETURN
    POP    BP
    POP    AX
%endif


    IRET




; *******************************
; Funktion 0001H: Mauszeiger einblenden
;
; Eingabe: AX=0001H 
;
; Ausgabe: keine
;
; *******************************
;
ShowMouse:

%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,33H
    CALL   DEBUG_TRACE_ENTRY
    POP    BP
    POP    AX
%endif

    MOV    AL,IORQ_MOUSE
    OUT    AUSGANG,AL

    MOV    AL,'s'   ; 's' = ShowMouse
    OUT    AUSGANG,AL


%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,33H
    CALL   DEBUG_TRACE_RETURN
    POP    BP
    POP    AX
%endif


    IRET






; *******************************
; Funktion 0002H: Mauszeiger ausblenden
;
; Eingabe: AX=0002H 
;
; Ausgabe: keine
;
; *******************************
;
HideMouse:

%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,33H
    CALL   DEBUG_TRACE_ENTRY
    POP    BP
    POP    AX
%endif


    MOV    AL,IORQ_MOUSE
    OUT    AUSGANG,AL

    MOV    AL,'h'   ; 'h' = HideMouse
    OUT    AUSGANG,AL


%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,33H
    CALL   DEBUG_TRACE_RETURN
    POP    BP
    POP    AX
%endif



    IRET





; *******************************
; Funktion 0003H: Get Parameter
;
; Eingabe: AX=0003H 
;
; Ausgabe  CX: X - Koordinate Cursor
;          DX: Y - Koordinate Cursor
;          BX: Tastenstatus
;
; RETURN:  BX    Button status: bit 0 = left button down   (BX & 1) = 1
;                               bit 1 = right button down  (BX & 2) = 2
;                               bit 2 = center button down (BX & 4) = 4
;          CX    X coordinate (horizontal)    divide by 8 for text clm
;          DX    Y coordinate (vertical)      divide by 8 for text line
;
; *******************************
; Get Parameter
;
ReadMouse:

    PUSH   AX

    MOV    AL,IORQ_MOUSE
    OUT    AUSGANG,AL

    MOV    AL,'r'   ; 'r' = ReadMouse
    OUT    AUSGANG,AL

    ; 1. Byte = Button
    IN     AL,AUSGANG
    MOV    BH,0
    MOV    BL,AL

    ; 2. Byte = HI(X)
    IN     AL,AUSGANG
    MOV    CH,AL

    ; 3. Byte = LO(X)
    IN     AL,AUSGANG
    MOV    CL,AL

    ; 4. Byte = HI(Y) 
    IN     AL,AUSGANG
    MOV    DH,AL

    ; 5. Byte = LO(Y)
    IN     AL,AUSGANG
    MOV    DL,AL

    POP    AX




    IRET
