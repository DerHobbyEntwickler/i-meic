
; ******************************************************
; ** Interrupt 13h: Disketten und Festplattenzugriffe **
; ******************************************************

; ******************************
; *   Vereinbarungsteil DISK   *
; ******************************

%include 'EQUDISK.ASM'


; ******************************
; *  Speichervariablen DISK    *
; ******************************

INT13_Drive   DB 0

INT13_Track   DW 0

INT13_Head    DB 0

INT13_Sector  DB 0

INT13_Sectors_to_RWV DB 0

INT13_FKT_RWV DB 0



DISK_SPT_P1   DB 0

DISK_HC_P1    DB 0

              DW 0

DISK_FDD_CNT  DB 0
DISK_HDD_CNT  DB 0

DISK_ERROR    DB 0

SECTOR_SUMME  DW 0

SECTOR_SUMME2 DW 0

              DW 0


; ---------------------------------------




INT_13:


    CMP    AH,00H
    JNE    INT_13_01
    JMP    INT13_RESET_DISK_SYSTEM          ; RESET DISK


INT_13_01:
    CMP    AH,01H
    JNE    INT_13_02
    JMP    INT13_F01          ; GET STATUS OF LAST OPERATION 


INT_13_02:
    CMP    AH,02H
    JNE    INT_13_03
    JMP    INT13_DISK_RWV                   ; READ DISK


INT_13_03:
    CMP    AH,03H
    JNE    INT_13_04
    JMP    INT13_DISK_RWV                   ;WRITE DISK


INT_13_04:
    CMP    AH,04H
    JNE    INT_13_05
    JMP    INT13_DISK_RWV                   ; Sektor Verify (AH = 04H)


INT_13_05:
    CMP    AH,05H
    JNE    INT_13_08
    JMP    INT13_F05                        ; Spur formatieren (AH = 05H)


INT_13_08:
    CMP    AH,08H
    JNE    INT_13_15
    JMP    INT13_PARAMETERS                 ;GET DISK PARAMETERS


INT_13_15:
    CMP    AH,15H
    JNE    INT_13_16
    JMP    INT13_GET_DISK_TYPE              ;GET DISK TYPE


INT_13_16:
    CMP    AH,16H
    JNE    INT_13_18
    JMP    INT13_Change_of_Disk_Status      ;Change of Disk Status


INT_13_18:
    CMP    AH,18H
    JNE    INT_13_41
    JMP    INT13_F18                        ;Set Media Type for Format (Diskette) (AH = 18H)


INT_13_41:
    CMP    AH,41H
    JNE    INT_13_NOT_FOUND
    JMP    INT13_AH_41                ;






INT_13_NOT_FOUND:

; Interrupt-Funktion nicht gefunden
%if ERROR_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,13H
    CALL   DEBUG_TRACE_UNSUPPORTED
    POP    BP
    POP    AX
%endif
    ; CY=1 -> Fehler
    STC                 ; SET CARRY FLAG


    JMP    END_WITH_CARRY_FLAG




; ****************************************
; Funktion 00h: Laufwerk initialisieren
;
; Eingabe: AH=00h
;          DL=Laufwerknummer 
; Ausgabe: Carry-Flag zeigt Fehler an
;          AH=Fehlercode
;
; Folgende Laufwerknummern gelten (Bit 7 ist bei HD gesetzt):
; 0: alle Laufwerke
; 1: Disketten-Laufwerk A
; 2: Disketten-Laufwerk B
; 80h: 1. Festplatte
; 81h: 2. Festplatte
; . . . usw.
; ****************************************
INT13_RESET_DISK_SYSTEM:


%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,13H
    CALL   DEBUG_TRACE_ENTRY
    POP    BP
    POP    AX
%endif

    PUSH  AX
    PUSH  DX
    PUSH  DS


    PUSH  CS
    POP   DS


    MOV   AL,DL
    AND   AL,10000000B
    CMP   AL,0
    JNZ   INT13_F00_A

; Bit 7=0 -> Anfrage fuer ein FDD

    CMP   DL,[ds:DISK_FDD_CNT]
    JC    INT13_00_LW_OK


; Bit 7=1 -> Anfrage fuer ein HDD
INT13_F00_A:

    AND   DL,01111111B  ; Bit 7 loeschen

    CMP   DL,[ds:DISK_HDD_CNT]
    JC    INT13_00_LW_OK



; ************************
; INT13 FKT00
;
; *** NICHT *** vorhandenes Laufwerk
; ************************

    POP    DS
    POP    DX
    POP    AX


    MOV    AX,00H       ; 0 : nicht vorhanden


%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,13H
    CALL   DEBUG_TRACE_RETURN_ERROR
    POP    BP
    POP    AX
%endif



    ; CY=1 -> Fehler
    STC                 ; SET CARRY FLAG

    JMP    END_WITH_CARRY_FLAG





; ************************
; INT13 FKT00
;
; Rueckgabe fuer ein 
; vorhandenes Laufwerk (DISK oder HDD)
; ************************
INT13_00_LW_OK:

    POP    DS
    POP    DX
    POP    AX

    MOV    AX,00H       ; 0 : nicht vorhanden

%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,13H
    CALL   DEBUG_TRACE_RETURN
    POP    BP
    POP    AX
%endif

    CLC                 ; CLEAR CARRY FLAG SUCCESFUL


    JMP    END_WITH_CARRY_FLAG





; ****************************************
; Funktion 01h: Laufwerkstatus lesen
; GET_STATUS_LAST_OPERATION
;
; Eingabe: AH=01h
;          DL=Laufwerknummer 
; Ausgabe: Carry-Flag zeigt Fehler an
;          AH=Fehlercode
; Folgende Laufwerknummern gelten:
; 0: alle Laufwerke
; 1: Disketten-Laufwerk A
; 2: Disketten-Laufwerk B
; 80h: 1. Festplatte
; 81h: 2. Festplatte
; . . . usw.
; ****************************************

INT13_F01:

%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,13H
    CALL   DEBUG_TRACE_ENTRY
    POP    BP
    POP    AX
%endif


; Ergebnis wie Referenzsystem MS-DOS 4.01 im Emulator
    MOV    AX,00H       ; 0 : nicht vorhanden


    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,13H
    CALL   DEBUG_TRACE_RETURN
    POP    BP
    POP    AX


    CLC                 ; CLEAR CARRY FLAG SUCCESFUL


    JMP    END_WITH_CARRY_FLAG






; ****************************************
; ** Funktion 02h: Sektoren lesen       **
; ** Funktion 03h: Sektoren schreiben   **
; ** Funktion 04h: Sektoren vergleichen **
; ****************************************
; Eingabe: AH=02h 
;          DL=Laufwerknummer
;          DH=Kopfnummer
;          CH=Spur-Nummer
;          CL=Sektor-Nummer
;          AL=Sektorenanzahl
;          ES:BX=Adresse des Lesepuffers
;                (512 Byte je Sektor)
;
;LBA = (C × HPC + H) × SPT + (S − 1)
;MAX NUMBERS C = 0X3FF, H = 0XFF, S = 0X3F
;AH = 02h
;AL = number of sectors to read (must be nonzero)
;CH = low eight bits of cylinder number
;CL = sector number 1-63 (bits 0-5)
;     high two bits of cylinder (bits 6-7, hard disk only)
;DH = head number
;DL = drive number (bit 7 set for hard disk)
;ES:BX -> data buffer

; Ausgabe: Carry-Flag zeigt Fehler an
;          AH=Fehlercode
;
; **************************************

INT13_DISK_RWV:

%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,13H
    CALL   DEBUG_TRACE_ENTRY
    POP    BP
    POP    AX
%endif


; Register retten
    PUSH   AX
    PUSH   BX
    PUSH   CX
    PUSH   DX
    PUSH   DS
    PUSH   ES

    PUSH   AX

    MOV    AX,CS
    MOV    DS,AX

    POP    AX

    MOV    [ds:INT13_Sectors_to_RWV],AL

    MOV    [ds:INT13_FKT_RWV],AH

    MOV    [ds:INT13_Drive],DL

    MOV    [ds:INT13_Head],DH

    MOV    AH,CL
    SHR    AH,1
    SHR    AH,1
    SHR    AH,1
    SHR    AH,1
    SHR    AH,1
    SHR    AH,1
    MOV    AL,CH
    MOV    [ds:INT13_Track],AX

    AND    CL, 03FH  ; 0011 1111B
    MOV    [ds:INT13_Sector],CL


    ; Ruecksetzen des DISK_ERROR-Bytes
    MOV    AL, 0
    MOV    [ds:DISK_ERROR], AL



; *******************************
; Auswahl der vorhandenen Laufwerke

    MOV   AL,DL
    AND   AL,10000000B
    CMP   AL,0
    JNZ   INT13_DISK_RWV_A

; Bit 7=0 -> Anfrage fuer ein FDD

    CMP   DL,[ds:DISK_FDD_CNT]
    JC    INT13_DISK_RWV_Schleife_FD


; Bit 7=1 -> Anfrage fuer ein HDD
INT13_DISK_RWV_A:

    AND   DL,01111111B  ; Bit 7 loeschen

    CMP   DL,[ds:DISK_HDD_CNT]
    JC    INT13_DISK_RWV_Schleife_HD




    JMP    INT13_DISK_RWV_END_ERR


; *******************************


INT13_DISK_RWV_Schleife_FD:

    MOV   AL, FD_SPT_P1
    MOV   [ds:DISK_SPT_P1], AL

    MOV   AL, FD_HC_P1
    MOV   [ds:DISK_HC_P1], AL

    JMP   INT13_DISK_RWV_Schleife


; *******************************


INT13_DISK_RWV_Schleife_HD:

    MOV   AL, HD_SPT_P1
    MOV   [ds:DISK_SPT_P1], AL

    MOV   AL, HD_HC_P1
    MOV   [ds:DISK_HC_P1], AL


; *******************************


INT13_DISK_RWV_Schleife:


    CALL   INT13_DISK_RWV_one_Sektor



    MOV    AL,[ds:INT13_Sectors_to_RWV]
    DEC    AL

    CMP    AL,0
    JNZ    INT13_DISK_RWV_01

    JMP    INT13_DISK_RWV_END_TEST
;    JMP    INT13_DISK_RWV_END_OK


INT13_DISK_RWV_01:

; RWV eines weiteren Sektors

    MOV    [ds:INT13_Sectors_to_RWV],AL

    MOV    AL,[ds:INT13_Sector]
    INC    AL
    MOV    [ds:INT13_Sector], AL
    CMP    AL, [ds:DISK_SPT_P1]     ; SPT
    JNZ    INT13_DISK_RWV_Schleife

; Sektor Zahl pro Spur erreicht, daher
; naechster Sektor auf dem naechsten Kopf (Seite der Diskette)

    MOV    AL, 1
    MOV    [ds:INT13_Sector], AL

    MOV    AL, [ds:INT13_Head]
    INC    AL
    MOV    [ds:INT13_Head], AL
    CMP    AL, [ds:DISK_HC_P1]    ; Kopfzahl von 0..1
    JNZ    INT13_DISK_RWV_Schleife

; Sektor Zahl pro Spur erreicht, daher
; naechster Sektor auf der anderen Seite der Diskette (naechster Kopf)

    MOV    AL,0
    MOV    [ds:INT13_Head],AL

    MOV    AX, [ds:INT13_Track]
    INC    AX
    MOV    [ds:INT13_Track],AX

    JMP    INT13_DISK_RWV_Schleife





INT13_DISK_RWV_one_Sektor:


; i-meic

    MOV    AL,IORQ_STHD
    OUT    AUSGANG,AL

; 1. SECTOR
    MOV    AL,[ds:INT13_Sector]
    OUT    AUSGANG,AL

; 2. TRACK
    MOV    AX,[ds:INT13_Track]
    OUT    AUSGANG,AL
    MOV    AL,AH
    OUT    AUSGANG,AL

; 3. HEAD
    MOV    AL, [ds:INT13_Head]
    OUT    AUSGANG,AL

; 3. DISKNO
    MOV    AL,[ds:INT13_Drive]
    OUT    AUSGANG,AL



; RWV-Verteiler
    MOV    AL,[ds:INT13_FKT_RWV]

    CMP    AL, 03H        ; WRITE
    JZ     INT13_DISK_Write_one_Sektor

    CMP    AL, 04H        ; VERIFY
    JZ     INT13_DISK_Verify_one_Sektor

; ... ansonsten weiter mit READ


; Achtung !!!
; in BX wird der Zeiger auf den Quell/Zielpuffer
; uebergeben. BX wird um 512 Byte erhoeht und
; wird im naechsten Durchlauf weiter benoetigt !!!
;
;********************************
;**    DISK Read one Sector    **
;********************************

INT13_DISK_Read_one_Sektor:

    ; READ SECTOR (512Byte)

    MOV    AL, IORQ_READ_FAT12
    OUT    AUSGANG,AL


    MOV    CX, 512


INT13_READ_IN_LOOP:           ;LOOP LABLE
    IN     AL, AUSGANG        ;READ BYTE
    MOV    [es:BX], AL        ;STORE BYTE
    INC    BX                 ;INC BX
    LOOP   INT13_READ_IN_LOOP ;LOOP UNTIL DONE


    RET






;********************************
;**    DISK Write one Sector   **
;********************************

INT13_DISK_Write_one_Sektor:

    ; Write SECTOR (512Byte)

    MOV    AL, IORQ_WRITE_FAT12
    OUT    AUSGANG,AL


    MOV    CX, 512


INT13_WRITE_IN_LOOP:         ;LOOP LABLE
    MOV    AL, [es:BX]       ;LOAD BYTE
    OUT    AUSGANG,AL        ;WRITE BYTE
    INC    BX                 ;INC BX
    LOOP   INT13_WRITE_IN_LOOP ;LOOP UNTIL DONE


    RET






;**********************************
;**    DISK Verify one Sector    **
;**********************************

INT13_DISK_Verify_one_Sektor:

    ; READ SECTOR (512Byte)

    MOV    AL, IORQ_READ_FAT12
    OUT    AUSGANG,AL

    PUSH   BX

    MOV    CX, 512
    MOV    AH, [ds:DISK_ERROR]

INT13_VERIFY_IN_LOOP_01:      ;LOOP LABLE
    IN     AL, AUSGANG        ;READ BYTE
    CMP    AL,[es:BX]         ;COMPARE BYTE
    JZ     INT13_VERIFY_IN_LOOP_02

    MOV    AH, 4

INT13_VERIFY_IN_LOOP_02:
    INC    BX                 ;INC BX
    LOOP   INT13_VERIFY_IN_LOOP_01 ;LOOP UNTIL DONE

    MOV    [ds:DISK_ERROR], AH



    IN     AL, AUSGANG  
    MOV    CL,AL

    IN     AL, AUSGANG  
    MOV    CH,AL

    MOV    [ds:SECTOR_SUMME], CX



    POP    BX

; Berechnung der Sektor-Summe
    MOV    CX, 512
    MOV    DX, 0000
    MOV    AX, DX

INT13_VERIFY_SUM_LOOP:    ; Schleifenlabel
    MOV    AL, [es:BX]  ; Lese Sektor-Byte
    ; Summieren der Sektorinhalte
    ADD    DX, AX       ; DX:=DX+AX
    ; INC Zeiger auf das aktuelle Sektor-Byte
    INC    BX
    LOOP   INT13_VERIFY_SUM_LOOP ; LOOP UNTIL DONE


    MOV    CX, [ds:SECTOR_SUMME]
    CMP    DX, CX

    JZ     INT13_VERIFY_END

    MOV    AL, 4
    MOV    [ds:DISK_ERROR], AL


INT13_VERIFY_END:


    RET


; -----------------


INT13_DISK_RWV_END_TEST:

    MOV    AL, [ds:DISK_ERROR]
    CMP    AL, 0
    JNZ    INT13_DISK_RWV_END_ERR


;**********************************
;**   DISK RWV Ende ohne Fehler  **
;**********************************
;
INT13_DISK_RWV_END_OK:

    POP    ES
    POP    DS
    POP    DX
    POP    CX
    POP    BX
    POP    AX

    MOV    AH, 00H    ; STATUS 00 SUCCESSFULL

%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,13H
    CALL   DEBUG_TRACE_RETURN
    POP    BP
    POP    AX
%endif

    CLC               ;CLEAR CARRY FLAG SUCCESFUL


    JMP    END_WITH_CARRY_FLAG



;************************************
;**  DISK RWV Ende mit Fehlercode  **
;************************************
;
INT13_DISK_RWV_END_ERR:

    POP    ES
    POP    DS
    POP    DX
    POP    CX
    POP    BX
    POP    AX

    MOV    AH, 04H    ;Fehlercode 4 = data did not verify correctly

%if ERROR_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,13H
    CALL   DEBUG_TRACE_RETURN_ERROR
    POP    BP
    POP    AX
%endif

    STC               ;SET CARRY FLAG ERROR


    JMP    END_WITH_CARRY_FLAG









; ****************************************
; Funktion 05H: Sektor Format
;
; Eingabe: AH=05H (Sektor Format)
;          ES:BX Zeiger auf Tabelle  (ES = Segment, BX = Offset)
;
; Ausgabe: CY: 0, kein Fehler
;          CY: 1, AH: Fehlercode 
;
; Byte   Bemerkung
;   0  - Spurnummer
;   1  - Kopfnummer
;   2  - Sektornummer
;   3  - Bytes pro Sektor (00=128, 01=256,
;                          02=512, 03=1024)
;
; ****************************************

INT13_F05:


%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,13H
;    CALL   DEBUG_TRACE_ENTRY
    CALL   DEBUG_TRACE_RETURN_ERROR
    POP    BP
    POP    AX
%endif



    JMP    END_WITH_CARRY_FLAG









; ****************************************
; Funktion 08H: PARAMETERS
;
; Eingabe: AH=08H 
;          DL=Laufwerknummer
;             (0=A:, 1=2nd floppy, 80h=drive 0, 81h=drive 1)
;
; Ausgabe: AH = status (see INT 13,STATUS)
;          BL = CMOS drive type
;               01 - 5Zoll  360K 03 - 3Zoll 720K
;               02 - 5Zoll 1.2Mb 04 - 3Zoll 1.44Mb
;          CH = cylinders (0-1023 dec. see below)
;          CL = sectors per track (see below)
;          DH = number of sides (0 based)
;          DL = number of drives attached
;          ES:DI = pointer to 11 byte Disk Base Table (DBT)
;          CF = 0 if successful
;             = 1 if error
; ****************************************


INT13_PARAMETERS:


%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,13H
    CALL   DEBUG_TRACE_ENTRY
    POP    BP
    POP    AX
%endif


    PUSH  DS


    PUSH  CS
    POP   DS


    MOV   AL,DL
    AND   AL,10000000B
    CMP   AL,0
    JNZ   INT13_F08_A

; Bit 7=0 -> Anfrage fuer ein FDD

    CMP   DL,[ds:DISK_FDD_CNT]
    JC    INT13_08_FDD


; Bit 7=1 -> Anfrage fuer ein HDD
INT13_F08_A:

    AND   DL,01111111B  ; Bit 7 loeschen

    CMP   DL,[ds:DISK_HDD_CNT]
    JC    INT13_08_HDD



; ************************
; INT13 FKT08 - PARAMETERS
;
; Rueckgabe PARAMETERS fuer ein 
; *** NICHT *** vorhandenes Laufwerk
; ************************

    POP    DS


%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,13H
    CALL   DEBUG_TRACE_RETURN_ERROR
    POP    BP
    POP    AX
%endif

    MOV   AH,07H  ; AH=Fehlercode
    STC                 ; Fehler


    JMP    END_WITH_CARRY_FLAG




; ************************
; INT13 FKT08 - FDD-PARAMETERS
;
; Rueckgabe PARAMETERS fuer ein 
; vorhandenes Laufwerk
; ************************


INT13_08_FDD:


    MOV    AX,BIOS_Segment
    MOV    ES,AX

    MOV    AX,INT_1E
    MOV    DI,AX



    MOV    AL,00H            ; STATUS 00 SUCCESSFULL
    MOV    BL,INT13_08_BL    ; 
    MOV    CX,FD_INT13_08_CX ;
    MOV    DH,FD_HC          ; number of sides (0 based) 1 = 2 Seiten

    MOV    DL,[ds:DISK_FDD_CNT] ; number of drives attached = 1 Diskettenlaufwerk


%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,13H
    CALL   DEBUG_TRACE_RETURN
    POP    BP
    POP    AX
%endif

    POP    DS

    CLC                 ;CLEAR CARRY FLAG SUCCESFUL	


    JMP    END_WITH_CARRY_FLAG





; ************************
; INT13 FKT08 - HDD-PARAMETERS
;
; Rueckgabe PARAMETERS fuer ein 
; vorhandenes Laufwerk
; ************************
INT13_08_HDD:


    MOV    AX,BIOS_Segment
    MOV    ES,AX

    MOV    AX,INT_1E
    MOV    DI,AX



    MOV    AX,0000H          ; STATUS 00 SUCCESSFULL
    MOV    BL,00H            ; 
    MOV    CX,HD_INT13_08_CX ;
    MOV    DH,HD_HC          ; number of sides (0 based) 1 = 2 Seiten

    MOV    DL,[ds:DISK_HDD_CNT] ; number of drives attached = 1 Diskettenlaufwerk


%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,13H
    CALL   DEBUG_TRACE_RETURN
    POP    BP
    POP    AX
%endif

    POP    DS

    CLC                 ;CLEAR CARRY FLAG SUCCESFUL	



    JMP    END_WITH_CARRY_FLAG








; ****************************************
; Funktion 15H: GET_DISK_TYPE
;
; Eingabe: AH=15H (Read DASD Type)
;          DL=Laufwerknummer
;          DH=Kopfnummer (1 - 2)
;          CH=Spurnummer
;          CL=Sektornummer (0 - 17)
;
; Ausgabe: 
;          CY: 0 --> kein Fehler
;          AH = status
;               0 : nicht vorhanden
;               1 : Diskette besitzt keine Change Line
;               2 : Diskette besitzt eine Change Line
;               3 : Festplatte 
;
;          CY: 1 --> Fehler
;          AH = Fehlercode
;          DL = Laufwerk
;
; ****************************************


INT13_GET_DISK_TYPE:


%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,13H
    CALL   DEBUG_TRACE_ENTRY
    POP    BP
    POP    AX
%endif

    PUSH  AX
    PUSH  DX
    PUSH  DS


    PUSH  CS
    POP   DS


    MOV   AL,DL
    AND   AL,10000000B
    CMP   AL,0
    JNZ   INT13_F15_A

; Bit 7=0 -> Anfrage fuer ein FDD

    CMP   DL,[ds:DISK_FDD_CNT]
    JC    INT13_15_LW_A


; Bit 7=1 -> Anfrage fuer ein HDD
INT13_F15_A:

    AND   DL,01111111B  ; Bit 7 loeschen

    CMP   DL,[ds:DISK_HDD_CNT]
    JC    INT13_15_LW_C




; *** FEHLER ***
; ************************
; INT13 FKT15 - GET_DISK_TYPE
;
; Rueckgabe des DISK_TYPE fuer ein 
; *** NICHT *** vorhandenes Laufwerk
; ************************

    POP    DS
    POP    DX
    POP    AX


    MOV    AH,00H       ; 0 : nicht vorhanden


%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,13H
    CALL   DEBUG_TRACE_RETURN_ERROR
    POP    BP
    POP    AX
%endif



    ; CY=1 -> Fehler
    STC                 ; SET CARRY FLAG

    JMP    END_WITH_CARRY_FLAG





; ************************
; INT13 FKT15 - GET_DISK_TYPE fuer FDD
;
; Rueckgabe des DISK_TYPE fuer ein 
; vorhandenes Disketten-Laufwerk
; ************************
INT13_15_LW_A:

    POP    DS
    POP    DX
    POP    AX


;    MOV    AH,00H       ; 0 : nicht vorhanden
    MOV    AH,01H       ; 1 Diskette besitzt keine Change Line

; Ergebnis wie Referenzsystem MS-DOS 3.11 im Emulator
;
;    MOV    AH,02H       ; 2 : Diskette besitzt eine Change Line

%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,13H
    CALL   DEBUG_TRACE_RETURN
    POP    BP
    POP    AX
%endif

    CLC                 ; CLEAR CARRY FLAG SUCCESFUL


    JMP    END_WITH_CARRY_FLAG






; ************************
; INT13 FKT15 - GET_DISK_TYPE fuer HDD
;
; Rueckgabe des DISK_TYPE fuer eine 
; vorhandene Festplatte
; ************************

INT13_15_LW_C:

    POP    DS
    POP    DX
    POP    AX


    MOV    AH,03H       ; Festplatte

%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,13H
    CALL   DEBUG_TRACE_RETURN
    POP    BP
    POP    AX
%endif

    CLC                 ; CLEAR CARRY FLAG SUCCESFUL


    JMP    END_WITH_CARRY_FLAG








; ****************************************
; Funktion 16H: Change of Disk Status (Diskette) (AH = 16H)
;
; Eingabe: AH = 16h
;          DL = drive number (0=A:, 1=2nd floppy, 80h=drive 0, 81h=drive 1)

;
; Ausgabe: AH = 00 no disk change
;             = 01 disk changed
;          CF = set if disk has been removed or an error occurred
;
; ****************************************

INT13_Change_of_Disk_Status:


%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,13H
    CALL   DEBUG_TRACE_ENTRY
    POP    BP
    POP    AX
%endif

    MOV    AH,00H       ; 

    CLC                 ; CLEAR CARRY FLAG SUCCESFUL


    JMP    END_WITH_CARRY_FLAG









; ****************************************
; Funktion 18H: Set Media Type for Format (Diskette)
;
; Eingabe: AH: 18H (Set Media Typ)
;          CH Zahl der Spuren (Lowbyte)
;          CL Bit 6/7 Tracks 0-5 Sekt.
;          DL Drive
;
; Ausgabe: AH: Statuscode
;          ES:DI Zeiger auf Parameter 
;          In Registerpaar ES:DI findet sich ein Zeiger
;          auf eine 11 Byte lange Parametertabelle
;
; ****************************************
; In CH werden die unteren 8 Bit der Spurzahl übergeben. Die Bits 6 und 7 in CL enthalten
; die höheren Bits der Spurzahl, während in den Bits 0 bis 5 die Zahl der Sektoren pro Spur
; steht. In DL wird die Laufwerksnummer übergeben. Nach dem Aufruf steht in AH der
; Statuscode mit folgender Bedeutung:
;  00H if requested combination supported
;  01H if function not available
;  0CH if not suppported or drive type unknown
;  80H if there is no media in the drive
;
INT13_F18:




%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,13H
    CALL   DEBUG_TRACE_ENTRY
    POP    BP
    POP    AX
%endif



    PUSH  CS
    POP   DS


    MOV   AL,DL
    AND   AL,10000000B
    CMP   AL,0
    JNZ   INT13_F18_A

; Bit 7=0 -> Anfrage fuer ein FDD

    CMP   DL,[ds:DISK_FDD_CNT]
    JC    INT13_18_FDD


; Bit 7=1 -> Anfrage fuer ein HDD
INT13_F18_A:

    AND   DL,01111111B  ; Bit 7 loeschen

    CMP   DL,[ds:DISK_HDD_CNT]
    JC    INT13_18_HDD


%if ERROR_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,13H
    CALL   DEBUG_TRACE_RETURN_ERROR
    POP    BP
    POP    AX
%endif



INT13_18_FDD:
INT13_18_HDD:


; Laden des INT-Vektors INT1E
; in die Register ES und DI

    MOV    AX,BIOS_Segment
    MOV    ES,AX
    MOV    DI,INT_1E


    MOV    AH,00H       ; 


%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,13H
    CALL   DEBUG_TRACE_RETURN
    POP    BP
    POP    AX
%endif


    CLC                 ; CLEAR CARRY FLAG SUCCESFUL


    JMP    END_WITH_CARRY_FLAG






; *****************************************
; * IBM/MS INT 13 Extensions - INSTALLATION CHECK (AH=41H/BX=55AAH)
; *****************************************
; Diese Funktion prüft, ob die IBM/MS INT 13H Extensions installiert
; und unterstützt werden. Werte für Hauptversionen der Erweiterungen
; wurden in der folgenden Tabelle angegeben:
;
; Eingabe: AH = 41H
;          BX = 55AAH
;          DL = drive (80h-FFh)
;
; wenn nicht unterstuetzt:
; Ausgabe: CY=1
;          AH = 01H
;          BX = AA55H
;          CX = 00FFH
;
; *****************************************
INT13_AH_41:


%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,13H
    CALL   DEBUG_TRACE_ENTRY
    POP    BP
    POP    AX
%endif


    MOV    AH,01H       ; 
    MOV    BX,0AA55H    ; 
    MOV    CX,00FFH     ; 


%if DEBUG_MSG
    PUSH   AX
    PUSH   BP
    MOV    BP,AX
    MOV    AH,13H
    CALL   DEBUG_TRACE_RETURN_ERROR
    POP    BP
    POP    AX
%endif



    ; CY=1 -> Fehler
    STC                 ; SET CARRY FLAG

    JMP    END_WITH_CARRY_FLAG






;******************************************
;  IRET mit Uebertragung des CARRY-Flags
;******************************************
END_WITH_CARRY_FLAG:
    PUSH   AX               ;STORE AX
    PUSH   BX

    PUSHF                   ;STORE FLAGS
    POP   BX                ;GET BX = FLAGS

    PUSH  BP                ;STORE BP
    MOV   BP, SP            ;Copy SP to BP for use as index
    ADD   BP, 10            ; Offset 16, (Flags, CS, IP, AX, BX)
    MOV   AX, [BP]
    AND   AX, 0FFFEH        ;CLEAR CF = ZER0
    AND   BX, 0001H         ;ONLY CF 
    OR    AX, BX
    MOV   [BP], AX          ;SET CF AX
    POP   BP                ;RESTORE BASE POINTER

    POP   BX
    POP   AX                ;RESTORE AX

    IRET




; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



; *********************************
; BIOS-INIT - FDD_IN_EQUIP
;
;  BDA - Eintrag der FDD in das Equipment-Word
;
; Eingabe: keine
;
; Ausgabe: keine
;
; *********************************

FDD_IN_EQUIP:

    PUSH   AX
    PUSH   BX
    PUSH   CX
    PUSH   ES
    PUSH   DS

    PUSH   CS
    POP    DS

; Adresse BDA
    MOV    AX, 040H
    MOV    ES, AX
    MOV    BX,0010H

    MOV    CX,[es:BX]
;             FEDCBA9876543210
    AND    CX,1111111100111111B ; Ausblenden Bit 7 und 6

    XOR    AX,AX  ; AX=0

    MOV    AL, [ds:DISK_FDD_CNT]
    OR     AL, AL
    JZ     FDD_IN_EQUIP_DONE    ; Keine FDDs, nichts eintragen
    DEC    AL
	
    ; ... Shifts ...
    SHL    AX,1
    SHL    AX,1
    SHL    AX,1
    SHL    AX,1
    SHL    AX,1
    SHL    AX,1	
	
    OR     CX, AX
	
FDD_IN_EQUIP_DONE:
    MOV    [es:BX], CX
	


    POP    DS
    POP    ES
    POP    CX
    POP    BX
    POP    AX


    RET








; *********************************
;  i-meic Basisroutine DISK_COUNT
;
; Abfrage der Anzahl der erkannten FDD und HDD
;
; Eingabe: keine
;
; Ausgabe: keine
;
; *********************************

DISK_COUNT:

    PUSH   AX
    PUSH   DS

    MOV    AX, CS
    MOV    DS, AX

    MOV    AL,IORQ_LW_COUNT
    OUT    AUSGANG,AL

    IN     AL,AUSGANG  ; 1.Parameter -> FDD
    MOV    [ds:DISK_FDD_CNT], AL

    IN     AL,AUSGANG  ; 2.Parameter -> HDD
    MOV    [ds:DISK_HDD_CNT], AL

    POP    DS
    POP    AX

    RET






; ******************************
;  i-meic Basisroutine DISK_SHOW
;
; Anzeige der erkannten DISK (FDD und HDD)
;
; Eingabe: keine
;
; Ausgabe: keine
;
; ******************************

DISK_SHOW:

    MOV    AL,IORQ_LW_SHOW
    OUT    AUSGANG,AL

    RET
