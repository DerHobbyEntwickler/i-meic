



CONST

// {$DEFINE FDD_SIZE_160}
// {$DEFINE FDD_SIZE_360}
// {$DEFINE FDD_SIZE_720}
// {$DEFINE FDD_SIZE_1200}
{$DEFINE FDD_SIZE_1440}


{$IFDEF FDD_SIZE_160}
FDD_SPT : Word = 8; // 160KB Sector per Track, Sektorenzahl
FDD_HC  : Word = 0; // von 0..1, 0->1, 1->2, Kopfzahl (HEAD COUNT)
{$ENDIF}


{$IFDEF FDD_SIZE_360}
FDD_SPT : Word = 9; // 360KB Sector per Track, Sektorenzahl
FDD_HC  : Word = 1; // von 0..1, 0->1, 1->2
{$ENDIF}


{$IFDEF FDD_SIZE_720}
FDD_SPT : Word = 9; // 720KB Sector per Track, Sektorenzahl
FDD_HC  : Word = 1; // von 0..1, 0->1, 1->2
{$ENDIF}


{$IFDEF FDD_SIZE_1200}
FDD_SPT : Word = 15; // 1.2MB Sector per Track, Sektorenzahl
FDD_HC  : Word = 1; // von 0..1, 0->1, 1->2
{$ENDIF}


{$IFDEF FDD_SIZE_1440}
FDD_SPT : Word = 18; // 1.44MB Sector per Track, Sektorenzahl
FDD_HC  : Word = 1; // von 0..1, 0->1, 1->2, Kopfzahl (HEAD COUNT)
{$ENDIF}



{$DEFINE HDD_SIZE_8000}
// {$DEFINE HDD_SIZE_14000}


{$IFDEF HDD_SIZE_8000}
{
512 cylinders
2 heads
16 sectors
}
HDD_SPT : Word = 16; // Sector per Track, Sektorenzahl
HDD_HC  : Word = 1; // von 0..1, 0->1, 1->2, Kopfzahl (HEAD COUNT)
{$ENDIF}


{$IFDEF HDD_SIZE_14000}
{
896 cylinders
2 heads
16 sectors
}
HDD_SPT : Word = 16; // Sector per Track, Sektorenzahl
HDD_HC  : Word = 1; // von 0..1, 0->1, 1->2, Kopfzahl (HEAD COUNT)
{$ENDIF}








procedure Read_TIME_to_Device;
var
  TIME_Byte : Byte;
  TIME_Vektor_Zeiger : Word;


  procedure lade_Datum_und_Zeit_Vektor;
  begin

    // D 30 11 20 25 17 49 56
    //    0  1  2  3  4  5  6

    Date_and_Time_Vector[0]:=$30;
    Date_and_Time_Vector[1]:=$11;
    Date_and_Time_Vector[2]:=$20;
    Date_and_Time_Vector[3]:=$25;
    Date_and_Time_Vector[4]:=$17;
    Date_and_Time_Vector[5]:=$49;
    Date_and_Time_Vector[6]:=$56;

  end; // procedure lade_Datum_und_Zeit_Vektor;


begin


    case Device_List.RTC_Devive of

      Device_Serial : Datum_und_Zeit_von_UART_lesen;

  //    Device_Serial : lade_Datum_und_Zeit_Vektor;

      Device_ITP3_DS0 : begin
                          DEV_NR:=DEV_DS0;
                          ITP3_empfange_DATE_TIME;
                        end;

      Device_ITP3_DS1 : begin
                          DEV_NR:=DEV_DS1;
                          ITP3_empfange_DATE_TIME;
                        end;

      Device_ITP3_DS2 : begin
                          DEV_NR:=DEV_DS2;
                          ITP3_empfange_DATE_TIME;
                        end;

      Device_ITP3_DS3 : begin
                          DEV_NR:=DEV_DS3;
                          ITP3_empfange_DATE_TIME;
                        end;

    else

      lade_Datum_und_Zeit_Vektor;

    end; // case CONIN_Device of



  // D04042024192456
  //   0 1 2 3 4 5 6
  for TIME_Vektor_Zeiger:=0 to 6 do begin

    TIME_Byte:=Date_and_Time_Vector[TIME_Vektor_Zeiger];

    wait_until_IO_RD_goes_LOW;

    Write_byte_to_data_bus(TIME_Byte);

  end;



end; // Read_TIME_to_Device;







procedure CONST_to_Device;
begin


  case Device_List.CONIN_Device of

    Device_Serial : ConsoleStat:=CONST_von_UART_lesen;

    Device_ITP3_DS0 : begin
                        DEV_NR:=DEV_DS0;
                        ITP3_empfange_CONST;
                       end;

    Device_ITP3_DS1 : begin
                        DEV_NR:=DEV_DS1;
                        ITP3_empfange_CONST;
                       end;

    Device_ITP3_DS2 : begin
                        DEV_NR:=DEV_DS2;
                        ITP3_empfange_CONST;
                       end;

    Device_ITP3_DS3 : begin
                        DEV_NR:=DEV_DS3;
                        ITP3_empfange_CONST;
                       end;


  end; // case CONIN_Device of

  wait_until_IO_RD_goes_LOW;

  Write_byte_to_data_bus(ConsoleStat);

end; // CONST_to_Device;








procedure CONIN_to_Device;
var
  CONIN_Byte : Byte;
begin

  case Device_List.CONIN_Device of

    Device_Serial : UART_CONIN_loop;

    Device_ITP3_DS0 : begin
                        DEV_NR:=DEV_DS0;
                        ITP3_CONIN_Schleife;
                       end;

    Device_ITP3_DS1 : begin
                        DEV_NR:=DEV_DS1;
                        ITP3_CONIN_Schleife;
                       end;

    Device_ITP3_DS2 : begin
                        DEV_NR:=DEV_DS2;
                        ITP3_CONIN_Schleife;
                       end;

    Device_ITP3_DS3 : begin
                        DEV_NR:=DEV_DS3;
                        ITP3_CONIN_Schleife;
                       end;

  end;

  CONIN_Byte:=HI(ConsoleIn);

  wait_until_IO_RD_goes_LOW;

  Write_byte_to_data_bus(CONIN_Byte);

  CONIN_Byte:=LO(ConsoleIn);

  wait_until_IO_RD_goes_LOW;

  Write_byte_to_data_bus(CONIN_Byte);

end; // CONIN_to_Device;








procedure MOUSE_to_Device;
var
  Maus_Char : Char;
  Maus_Byte : Byte;
begin

  wait_until_WR_LOW;

  // 1. SECTOR
  wait_until_IO_WR_goes_LOW;
  Maus_Char:=CHR(Lese_Datenbus);

  wait_until_WR_LOW;

  if Maus_Char='r' then begin


    case Device_List.MOUSE_Device of

      Device_Serial : Maus_von_UART_lesen;

    else

      UART_WriteLn_Text('x34');

    end; // case MOUSE_Device of


    // 1. Byte = Button
    Maus_Byte:=RMouse.Button;
    wait_until_IO_RD_goes_LOW;
    Write_byte_to_data_bus(Maus_Byte);

    // 2. Byte = HI(X)
    Maus_Byte:=HI(RMouse.X);
    wait_until_IO_RD_goes_LOW;
    Write_byte_to_data_bus(Maus_Byte);

    // 3. Byte = LO(X)
    Maus_Byte:=LO(RMouse.X);
    wait_until_IO_RD_goes_LOW;
    Write_byte_to_data_bus(Maus_Byte);

    // 4. Byte = HI(Y)
    Maus_Byte:=HI(RMouse.Y);
    wait_until_IO_RD_goes_LOW;
    Write_byte_to_data_bus(Maus_Byte);

    // 5. Byte = LO(Y)
    Maus_Byte:=LO(RMouse.Y);
    wait_until_IO_RD_goes_LOW;
    Write_byte_to_data_bus(Maus_Byte);


  end // if Maus_Char='r' then
  else begin

    case Device_List.MOUSE_Device of

      Device_Serial : UART_Maus_INIT_ON_OFF(Maus_Char);

    else

      UART_WriteLn_Text('x35');

    end; // case MOUSE_Device of


  end; // else Maus_Char='r' then


end; // MOUSE_to_Device







procedure MOUSE_INI_ON_OFF_to_Device;
var
  Maus_Char : Char;
begin

  wait_until_WR_LOW;

  // 1. SECTOR
  wait_until_IO_WR_goes_LOW;
  Maus_Char:=CHR(Lese_Datenbus);


  case Device_List.MOUSE_Device of

    Device_Serial : UART_Maus_INIT_ON_OFF(Maus_Char);

  else

    UART_WriteLn_Text('x35');

  end; // case MOUSE_Device of


end; // MOUSE_INI_ON_OFF_to_Device











// noch nicht implementiert !!!!!!!!!!!!!!!!!!!!!!!!!
procedure LIST_to_Device;
begin

end; // LIST_to_Device;








// noch nicht implementiert !!!!!!!!!!!!!!!!!!!!!!!!!
procedure SOUND_to_Device;
begin

end; // SOUND_to_Device;









procedure STHD_to_Device;
var
  SECTOR, TRACK_L, TRACK_H, HEAD : Byte;
  TRACK_Word : Word;
  DRIVE_SPT : Word;
  DRIVE_HC : Word;
  HEAD_Word : Word;
begin

  wait_until_WR_LOW;

  // 1. SECTOR
  wait_until_IO_WR_goes_LOW;
  SECTOR:=Lese_Datenbus;
  wait_until_WR_LOW;

  // 2. TRACK_L
  wait_until_IO_WR_goes_LOW;
  TRACK_L:=Lese_Datenbus;
  wait_until_WR_LOW;

  // 3. TRACK_H
  wait_until_IO_WR_goes_LOW;
  TRACK_H:=Lese_Datenbus;
  wait_until_WR_LOW;

  // 4. HEAD
  wait_until_IO_WR_goes_LOW;
  HEAD:=Lese_Datenbus;
  wait_until_WR_LOW;

  // 5. DISKNO
  wait_until_IO_WR_goes_LOW;
  DISKNR:=Lese_Datenbus;


  // **************************
  // Umwandeln STH in LBA
  // **************************


  // TRACK_L
  DISK_LBA:=ByteToWord(TRACK_L);

  // TRACK_H
  TRACK_Word:=ByteToWord(TRACK_H);
  TRACK_Word:=TRACK_Word*256;
  TRACK_Word:=TRACK_Word+DISK_LBA;

  if DISKNR<$80 then begin
    // FDD
    DRIVE_HC:=FDD_HC+1;
    DRIVE_SPT:=FDD_SPT;
  end
  else begin
    // HDD
    DRIVE_HC:=HDD_HC+1;
    DRIVE_SPT:=HDD_SPT;
  end;


  // Beruecksichtigung der Anzahl der Koepfe des Drives
  TRACK_Word:=TRACK_Word*DRIVE_HC;
  // Addition der Kopfzahl
  HEAD_Word:=ByteToWord(HEAD);
  TRACK_Word:=TRACK_Word+HEAD_Word;
  TRACK_Word:=TRACK_Word*DRIVE_SPT;

  // SECTOR
  DISK_LBA:=ByteToWord(SECTOR);
  DISK_LBA:=DISK_LBA-1;

  // Ergebnis = Sektor_Nr_512
  DISK_LBA:=DISK_LBA+TRACK_Word;

  // DISK_LBA (Word) ist nun liearer Vektor von 0..letzten_Sektor


end; // STD_to_Device;













function Number_FDD : Byte;
var
  ANZ_DISK : Byte;
begin

  ANZ_DISK:=0;

  if Device_List.FDD_LW_A<>no_Device then
    INC(ANZ_DISK);

  if Device_List.FDD_LW_B<>no_Device then
    INC(ANZ_DISK);

  RESULT:=ANZ_DISK;

end; // Number_FDD;






function Number_HDD : Byte;
var
  ANZ_DISK : Byte;
  DISK_Zeiger : Word;
  DISK_Eintrag : Byte;
begin

  ANZ_DISK:=0;

  for DISK_Zeiger:=0 to 15 do begin

    DISK_Eintrag:=Device_List.HDD_table[DISK_Zeiger];

    if DISK_Eintrag<>no_Device then
      INC(ANZ_DISK);

  end;

  RESULT:=ANZ_DISK;

end; // Number_HDD;






procedure DISK_count_FDD_HDD;
var
  ANZ_DISK : Byte;
begin

  // 1. Anzahl FDD
  ANZ_DISK:=Number_FDD;

  wait_until_WR_LOW;

  wait_until_IO_RD_goes_LOW;

  Write_byte_to_data_bus(ANZ_DISK);


  // 2. Anzahl HDD
  ANZ_DISK:=Number_HDD;

  wait_until_WR_LOW;

  wait_until_IO_RD_goes_LOW;

  Write_byte_to_data_bus(ANZ_DISK);

end; // DISK_count_FDD_HDD;






procedure READ_FAT12;
var
  READ_Byte : Byte;
  SP_Zeiger : Word;
begin

  Laufwerke_Verteiler_READ;

  for SP_Zeiger:=0 to 511 do begin

    READ_Byte:=Sektor_Puffer[SP_Zeiger];

    wait_until_IO_RD_goes_LOW;

    Write_byte_to_data_bus(READ_Byte);

  end; // for Sektor_Puffer_Zeiger:=0 to 511 do

end; // READ_FAT12;





procedure WRITE_FAT12;
var
  WRITE_Byte : Byte;
  SP_Zeiger : Word;
begin

  for SP_Zeiger:=0 to 511 do begin

    wait_until_WR_LOW;

    wait_until_IO_WR_goes_LOW;

    WRITE_Byte:=Read_Byte_from_Databus;

    Sektor_Puffer[SP_Zeiger]:=WRITE_Byte;

  end;

  Laufwerke_Verteiler_WRITE;

end; // WRITE_FAT12;





// AK1 AK2 IODB / 00=AR 01=INT 02=... 18=
procedure Receive_DEBUG_Zellen;
var
  WRITE_Byte : Byte;
  DEBUG_array_counter : Word;
begin

  for DEBUG_array_counter:=0 to 18 do begin

    wait_until_WR_LOW;

    wait_until_IO_WR_goes_LOW;

    WRITE_Byte:=Read_Byte_from_Databus;

    DEBUG_array[DEBUG_array_counter]:=WRITE_Byte;

  end;

  DEBUG_an_UART_senden;

end; // Receive_DEBUG_Zellen;






procedure Receive_IORQ_VIDEO_SEND;
begin

  wait_until_WR_LOW;

  wait_until_IO_WR_goes_LOW;

  VIDEO_SEND_Routine:=Read_Byte_from_Databus;

  wait_until_WR_LOW;

  wait_until_IO_WR_goes_LOW;

  VIDEO_SEND_Param1:=Read_Byte_from_Databus;

  wait_until_WR_LOW;

  wait_until_IO_WR_goes_LOW;

  VIDEO_SEND_Param2:=Read_Byte_from_Databus;

  VIDEO_SEND_to_Device;

end; // Receive_IORQ_VIDEO_SEND;







procedure Send_IORQ_VIDEO_RESV;
begin

  wait_until_WR_LOW;

  wait_until_IO_WR_goes_LOW;

  VIDEO_GET_Routine:=Read_Byte_from_Databus;

  VIDEO_GET_to_Device;

  wait_until_IO_RD_goes_LOW;

  Write_byte_to_data_bus(VIDEO_GET_Param1);

  wait_until_IO_RD_goes_LOW;

  Write_byte_to_data_bus(VIDEO_GET_Param2);

end; // Send_IORQ_VIDEO_RESV;






procedure Write_VIDEO_SA;
var
  WRITE_Byte : Byte;
  VSA_Zeiger : Word;
begin

  for VSA_Zeiger:=0 to 20 do begin

    wait_until_WR_LOW;

    wait_until_IO_WR_goes_LOW;

    WRITE_Byte:=Read_Byte_from_Databus;

    Sektor_Puffer[VSA_Zeiger]:=WRITE_Byte;

  end;

  VIDEO_SA_to_Device;

end; // Write_VIDEO_SA;




// ***************************
// *** BIOS Read and Write ***
// ***************************


procedure READ_BIOS;
var
  READ_Byte : Byte;
  BIOS_Zeiger : Word;
begin

  READ_BIOS_Vektor_from_BIOS;

  for BIOS_Zeiger:=0 to 9 do begin

    READ_Byte:=BIOS_Vector[BIOS_Zeiger];

    wait_until_IO_RD_goes_LOW;

    Write_byte_to_data_bus(READ_Byte);

  end; // for BIOS_Zeiger:=0 to 9 do

end; // READ_BIOS






procedure WRITE_BIOS;
var
  WRITE_Byte : Byte;
  BIOS_Zeiger : Word;
begin

  for BIOS_Zeiger:=0 to 9 do begin

    wait_until_WR_LOW;

    wait_until_IO_WR_goes_LOW;

    WRITE_Byte:=Read_Byte_from_Databus;

    BIOS_Vector[BIOS_Zeiger]:=WRITE_Byte;

  end;

  WRITE_BIOS_Vektor_to_BIOS;

end; // procedure WRITE_BIOS







// *******************
// *** Device-List ***
// *******************


procedure READ_DevList;
var
  READ_Byte : Byte;
  DL_Zeiger : Word;
begin

  DevList_to_DevList_Vektor;

  for DL_Zeiger:=0 to 41 do begin

    READ_Byte:=DevList_Vector[DL_Zeiger];

    wait_until_IO_RD_goes_LOW;

    Write_byte_to_data_bus(READ_Byte);

  end; // for DL_Zeiger:=0 to 41 do

end; // READ_DevList











procedure Analyze_IO;
var
  IO_Wert : Byte;
begin


  if BitLow_WR_80 then begin

    IO_Wert:=Read_Byte_from_Databus;

    case IO_Wert of

      // IORQ-Routinen
      // =============

      // Zeichen von Konsole (Tastatur) lesen
      IORQ_CONIN       : CONIN_to_Device;

      // Abfrage des Konsolenstatus (Zeichen in Puffer vorhanden)
      IORQ_CONST       : CONST_to_Device;

      // Abfrage der Maus-Parameter
      IORQ_MOUSE       : MOUSE_to_Device;

      // Uebergabe von Sector/Track/Head/Disk vom uC an den SBC
      IORQ_STHD        : STHD_to_Device;

      // Abfrage der Anzahl der Laufwerke FDD und HDD
      IORQ_LW_COUNT    : DISK_count_FDD_HDD;

      // Anweisung zur Anzeige von Laufwerks- und Geraetedaten an CONOUT
      IORQ_LW_SHOW     : begin
                           Show_devices;
                           Show_Drivetables;
                         end;

      // Lesen eines Sektors
      IORQ_READ_FAT12  : READ_FAT12;

      // Schreiben eines Sektors
      IORQ_WRITE_FAT12 : WRITE_FAT12;

      // Senden von Debug-Informationen vom uC an den SBC
      IORQ_DEBUG       : Receive_DEBUG_Zellen;

      // Senden von Video-Befehlen mit Paramertern an den SBC (Umsetzung BIOS INT10H)
      IORQ_VIDEO_SEND  : Receive_IORQ_VIDEO_SEND;

      // Empfangen von Video-Befehlen mit Paramertern vom SBC (Umsetzung BIOS INT10H)
      IORQ_VIDEO_RESV  : Send_IORQ_VIDEO_RESV;

      // Einlesen von Datums- und Zeitwerten vom SBC
      IORQ_TIME        : Read_TIME_to_Device;

      // regelmaessige Uebertragung der Aenderungen im Video-RAM vom uC an
      // die Anzeigeeinheit (LCD, Monitor, usw)
      IORQ_VIDEO_SA_Teil : Write_VIDEO_SA;

      // Starten und Stoppen des SysTick-Signals vom PICO an den uC
      IORQ_START_SysTick : Start_SysTick;

      // Lesen der gespeicherten BIOS-Daten durch den uC vom Flash des PICO
      IORQ_READ_BIOS     : READ_BIOS;

      // Schreiben der BIOS-Daten in den Flash des PICO
      IORQ_WRITE_BIOS    : WRITE_BIOS;

      // Abrage der Liste der vom SBC erkannten Geraete (Serial, ITP3, Lokal)
      IORQ_READ_DevList  : READ_DevList;

    end; { case IO_Wert of }

  end; // if BitLow_WR_80

  wait_until_WR_LOW;

end; // Analyze_IO;









