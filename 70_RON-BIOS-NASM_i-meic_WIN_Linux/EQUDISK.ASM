
; **********************************************************
;   Vereinbarungsteil DISK
; **********************************************************

; FD_SIZE  EQU  160
; FD_SIZE  EQU  360
; FD_SIZE  EQU  720
; FD_SIZE  EQU 1200
%define FD_SIZE 1440



%if FD_SIZE == 160
  FD_SPT         EQU    8  ; 160KB Sector per Track, Sektorenzahl
  FD_SPT_P1      EQU FD_SPT+1 ;
  FD_HC          EQU    0  ; von 0..1, 0->1, 1->2 (Kopfzahl = Head Count)
  FD_HC_P1       EQU FD_HC+1 ;
  INT13_08_BL    EQU    0  ; 00 - 
  FD_INT13_08_CX EQU 2708H ; CHCL = 2708H
                            ; 0010 0111 0000 1000B
                            ; 00 1001 1100 = 09C = 156
                            ; 001001 = 09H = 8
%endif



%if FD_SIZE == 360
  FD_SPT         EQU    9  ; 360KB Sector per Track, Sektorenzahl
  FD_SPT_P1      EQU FD_SPT+1 ;
  FD_HC          EQU    1  ; von 0..1, 0->1, 1->2
  FD_HC_P1       EQU FD_HC+1 ;
  INT13_08_BL    EQU    1  ; 01 - 360KB
  FD_INT13_08_CX EQU 2709H ; CHCL = 2709H
                            ; 0010 0111 0000 1001B
                            ; 00 1001 1100 = 09C = 156
                            ; 001001 = 09H = 9
%endif



%if FD_SIZE == 720
  FD_SPT         EQU    9  ; 720KB Sector per Track, Sektorenzahl
  FD_SPT_P1      EQU FD_SPT+1 ;
  FD_HC          EQU    1  ; von 0..1, 0->1, 1->2
  FD_HC_P1       EQU FD_HC+1 ;
  INT13_08_BL    EQU    3  ; 03 - 720KB
  FD_INT13_08_CX EQU 4F09H ; CHCL = 4F09H
                            ; 0100 1111 0000 1001B
                            ; 01 0011 1100 = 13CH = 316
                            ; 001001 = 09H = 9
%endif



%if FD_SIZE == 1200
  FD_SPT         EQU    15 ; 1.2MB Sector per Track, Sektorenzahl
  FD_SPT_P1      EQU FD_SPT+1 ;
  FD_HC          EQU     1 ; von 0..1, 0->1, 1->2
  FD_HC_P1       EQU FD_HC+1 ;
  INT13_08_BL    EQU     2 ;  02 - 1.2MB
  FD_INT13_08_CX EQU 4F0FH ; CHCL = 4F0FH
                            ; 0100 1111 0000 1111B
                            ; 01 0011 1100 = 13CH = 316
                            ; 001111 = 0FH = 15
%endif



%if FD_SIZE == 1440
  FD_SPT         EQU    18 ; 1.44MB Sector per Track, Sektorenzahl
  FD_SPT_P1      EQU FD_SPT+1 ;
  FD_HC          EQU     1 ; von 0..1, 0->1, 1->2
  FD_HC_P1       EQU FD_HC+1 ;
  INT13_08_BL    EQU     4 ;   ok
  FD_INT13_08_CX EQU 4F12H ; CHCL = 4F12H
                            ; 0100 1111 0001 0010B
                            ; 01 0011 1100 = 013C = 316
                            ; 010010 = 12H = 18
%endif





%define HD_SIZE 8000
; HD_SIZE  EQU 14000



%if HD_SIZE == 8000
; 512 cylinders, 2 heads, 16 sectors
  HD_SPT         EQU    16  ; Sector per Track, Sektorenzahl
  HD_SPT_P1      EQU HD_SPT+1 ;
  HD_HC          EQU     1  ; von 0..1, 0->1, 1->2 (Kopfzahl = Head Count)
  HD_HC_P1       EQU HD_HC+1 ;
  HD_INT13_08_CX EQU 0FF50H ; CHCL = FF50H
                            ; 1111 1111 0101 0000B
                            ; 11 1111 1101 = 03FD = 1.021
                            ; 01 0000 = 10H = 16
                            ; 8364032
%endif


%if HD_SIZE == 14000
; 896 cylinders, 2 heads, 16 sectors
  HD_SPT         EQU    16  ; Sector per Track, Sektorenzahl
  HD_SPT_P1      EQU HD_SPT+1 ;
  HD_HC          EQU     1  ; von 0..1, 0->1, 1->2 (Kopfzahl = Head Count)
  HD_HC_P1       EQU HD_HC+1 ;
  HD_INT13_08_CX EQU 07FD0H ; CHCL = 7FD0H
                            ; 0111 1111 1101 0000B
                            ; 0011 1000 0000 = 896
                            ; 01 0000 = 10H = 16
                            ; 

%endif
