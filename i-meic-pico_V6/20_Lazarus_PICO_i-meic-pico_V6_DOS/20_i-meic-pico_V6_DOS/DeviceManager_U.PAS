unit DeviceManager_U;

{$mode objfpc}


interface


uses
  GlobalDEF_U,
  GlobalHW_U,
  SysUtils_U,
  UART_U,
  SysTick_U,
  BIOSAdmin_U,
  ITP3_SRV_U;



  procedure load_BootJMP_and_BIOS_into_SRAM;
  procedure Analyze_IO;
  procedure CONOUT_WriteLn_String(Anzeige_String : String);

  procedure DEVICE_CONTROL;
  procedure Laufwerke_Verteiler_READ;
  procedure Laufwerke_Verteiler_WRITE;

implementation


CONST

  // Befehlscode fuer IORQ
  IORQ_LED_Ein     = 01;
  IORQ_LED_Aus     = 02;

  IORQ_CONIN       = 04;
  IORQ_CONST       = 05;

  IORQ_LIST 	   = 09;
  IORQ_TIME 	   = 10;  // 0AH
  IORQ_SOUND       = 11;  // 0BH

  IORQ_LW_COUNT    = 12;  // 0CH
  IORQ_LW_SHOW     = 14;  // 0EH

  IORQ_READ_FAT12  = 15;  // 0FH
  IORQ_WRITE_FAT12 = 16;  // 10H

  IORQ_STHD        = 17;  // 11H
  IORQ_DEBUG       = 18;  // 12H

  IORQ_VIDEO_SEND  = 20;  // 14H
  IORQ_VIDEO_RESV  = 21;  // 15H

  IORQ_VIDEO_SA_Teil = 24;  // 18H

  IORQ_START_SysTick = 26;  // 1AH

  IORQ_MOUSE         = 27;  // 1BH

  IORQ_READ_BIOS     = 28;  // 1CH
  IORQ_WRITE_BIOS    = 29;  // 1DH

  IORQ_READ_DevList  = 30;  // 1EH


CONST
{$I BIOS.INC}




// **********************************************
//     Geraete_Manager
// **********************************************








procedure VIDEO_SA_to_Device;
begin

  case Device_List.CONOUT_Device of

    Device_Serial : Write_VIDEO_SA_an_UART_senden;

    Device_ITP3_DS0 : begin
                        DEV_NR:=DEV_DS0;
                        ITP3_sende_VIDEO_SA;
                      end;

    Device_ITP3_DS1 : begin
                        DEV_NR:=DEV_DS1;
                        ITP3_sende_VIDEO_SA;
                      end;

    Device_ITP3_DS2 : begin
                        DEV_NR:=DEV_DS2;
                        ITP3_sende_VIDEO_SA;
                      end;

    Device_ITP3_DS3 : begin
                        DEV_NR:=DEV_DS3;
                        ITP3_sende_VIDEO_SA;
                      end;

  end; // case CONOUT_Device of

end; // VIDEO_SA_to_Device;







procedure VIDEO_SEND_to_Device;
begin

  case Device_List.CONOUT_Device of

    Device_Serial : VIDEO_SEND_an_UART_senden;

    Device_ITP3_DS0 : begin
                        DEV_NR:=DEV_DS0;
                        ITP3_sende_VIDEO_SEND;
                      end;

    Device_ITP3_DS1 : begin
                        DEV_NR:=DEV_DS1;
                        ITP3_sende_VIDEO_SEND;
                      end;

    Device_ITP3_DS2 : begin
                        DEV_NR:=DEV_DS2;
                        ITP3_sende_VIDEO_SEND;
                      end;

    Device_ITP3_DS3 : begin
                        DEV_NR:=DEV_DS3;
                        ITP3_sende_VIDEO_SEND;
                      end;

  end; // case CONOUT_Device of

end; // VIDEO_SEND_to_Device;







procedure VIDEO_GET_to_Device;
begin

  case Device_List.CONOUT_Device of

    Device_Serial : VIDEO_GET_von_UART_lesen;

    Device_ITP3_DS0 : begin
                        DEV_NR:=DEV_DS0;
                        ITP3_empfange_VIDEO_GET;
                      end;

    Device_ITP3_DS1 : begin
                        DEV_NR:=DEV_DS1;
                        ITP3_empfange_VIDEO_GET;
                      end;

    Device_ITP3_DS2 : begin
                        DEV_NR:=DEV_DS2;
                        ITP3_empfange_VIDEO_GET;
                      end;

    Device_ITP3_DS3 : begin
                        DEV_NR:=DEV_DS3;
                        ITP3_empfange_VIDEO_GET;
                      end;

  end; // case CONOUT_Device of

end; // VIDEO_GET_to_Device;






// **********************************************





procedure CONOUT_WriteLn_String(Anzeige_String : String);
var
  c1 : Char;
  Laenge : Byte;
  b1 : Byte;
begin

  VIDEO_SEND_Routine:=VIDEO_CONOUT;

  Laenge:=Length(Anzeige_String);
  for b1:=1 to Laenge do begin
    c1:=Anzeige_String[b1];
    ConsoleOut.Character:=CharToByte(c1);
    VIDEO_SEND_Param1:=ConsoleOut.Character;
    VIDEO_SEND_to_Device;
  end;

  ConsoleOut.Character:=CR;
  VIDEO_SEND_Param1:=ConsoleOut.Character;
  VIDEO_SEND_to_Device;

  ConsoleOut.Character:=LF;
  VIDEO_SEND_Param1:=ConsoleOut.Character;
  VIDEO_SEND_to_Device;

end; // CONOUT_WriteLn_String







procedure Show_Drivetables;
var
  LV_Zeiger : Word;
  Eintrag_Wert : Byte;
  LW_Buchstabe_Byte : Byte;
  LW_Buchstabe_Char : Char;
  Anzeige_String : String;
begin

  if Device_List.FDD_LW_A<>no_Device then begin

    Anzeige_String:='A: -> ';

    Eintrag_Wert:=Device_List.FDD_LW_A;

    case Eintrag_Wert of

 //     Device_lokal_Flash : Anzeige_String:=Anzeige_String+'lokal_Flash-FDD';
      Device_Serial      : Anzeige_String:=Anzeige_String+'Serial-FDD';
      Device_ITP3_DS0    : Anzeige_String:=Anzeige_String+'ITP3-FDD an DS0';
      Device_ITP3_DS1    : Anzeige_String:=Anzeige_String+'ITP3-FDD an DS1';
      Device_ITP3_DS2    : Anzeige_String:=Anzeige_String+'ITP3-FDD an DS2';
      Device_ITP3_DS3    : Anzeige_String:=Anzeige_String+'ITP3-FDD an DS3';

    end; // case Eintrag_Wert of

    CONOUT_WriteLn_String(Anzeige_String);

  end; // if FDD_LW_A<>no_Device then



  if Device_List.FDD_LW_B<>no_Device then begin

    Anzeige_String:='B: -> ';

    Eintrag_Wert:=Device_List.FDD_LW_B;

    case Eintrag_Wert of

  //    Device_lokal_Flash : Anzeige_String:=Anzeige_String+'lokal_Flash-FDD';
      Device_Serial      : Anzeige_String:=Anzeige_String+'Serial-FDD';
      Device_ITP3_DS0    : Anzeige_String:=Anzeige_String+'ITP3-FDD an DS0';
      Device_ITP3_DS1    : Anzeige_String:=Anzeige_String+'ITP3-FDD an DS1';
      Device_ITP3_DS2    : Anzeige_String:=Anzeige_String+'ITP3-FDD an DS2';
      Device_ITP3_DS3    : Anzeige_String:=Anzeige_String+'ITP3-FDD an DS3';

    end; // case Eintrag_Wert of

    CONOUT_WriteLn_String(Anzeige_String);

  end; // if FDD_LW_B<>no_Device then




  LW_Buchstabe_Byte:=$43;  // LW=C


  for LV_Zeiger:=0 to 15 do begin
    Eintrag_Wert:=Device_List.HDD_table[LV_Zeiger];
    if Eintrag_Wert<>no_Device then begin

      LW_Buchstabe_Char:=ByteToChar(LW_Buchstabe_Byte);
      Anzeige_String:=LW_Buchstabe_Char+': -> ';

      case Eintrag_Wert of

   //     Device_lokal_Flash : Anzeige_String:=Anzeige_String+'lokal_Flash-HDD';
        Device_Serial      : Anzeige_String:=Anzeige_String+'Serial-HDD';
        Device_ITP3_DS0    : Anzeige_String:=Anzeige_String+'ITP3-HDD an DS0';
        Device_ITP3_DS1    : Anzeige_String:=Anzeige_String+'ITP3-HDD an DS1';
        Device_ITP3_DS2    : Anzeige_String:=Anzeige_String+'ITP3-HDD an DS2';
        Device_ITP3_DS3    : Anzeige_String:=Anzeige_String+'ITP3-HDD an DS3';

      end; // case Eintrag_Wert of

      CONOUT_WriteLn_String(Anzeige_String);

    end; // if Eintrag_Wert<>no_Device then

    INC(LW_Buchstabe_Byte);

  end; // for LV_Zeiger:=0 to 15 do



end; // Show_Drivetables









procedure Show_devices;
var
  Anzeige_String : String;


  procedure Geraete_anzeigen_Device(CON_Device : Byte);
  begin
    case CON_Device of

      Device_Serial      : Anzeige_String:=Anzeige_String+'Serial';
  //    Device_lokal_Flash : Anzeige_String:=Anzeige_String+'lokal Flash';
      Device_ITP3_DS0    : Anzeige_String:=Anzeige_String+'ITP3 DS0';
      Device_ITP3_DS1    : Anzeige_String:=Anzeige_String+'ITP3 DS1';
      Device_ITP3_DS2    : Anzeige_String:=Anzeige_String+'ITP3 DS2';
      Device_ITP3_DS3    : Anzeige_String:=Anzeige_String+'ITP3 DS3';

    end;
  end; // Geraete_anzeigen_Device;


begin

  Anzeige_String:='VIDEO=';
  Geraete_anzeigen_Device(Device_List.CONOUT_Device);
  CONOUT_WriteLn_String(Anzeige_String);


  Anzeige_String:='KEYBOARD=';
  Geraete_anzeigen_Device(Device_List.CONIN_Device);
  CONOUT_WriteLn_String(Anzeige_String);


  if Device_List.LIST_Device<>no_Device then begin
    Anzeige_String:='PRINT=';
    Geraete_anzeigen_Device(Device_List.LIST_Device);
    CONOUT_WriteLn_String(Anzeige_String);
  end;


  if Device_List.SOUND_Device<>no_Device then begin
    Anzeige_String:='AUDIO=';
    Geraete_anzeigen_Device(Device_List.SOUND_Device);
    CONOUT_WriteLn_String(Anzeige_String);
  end;



  if Device_List.RTC_Devive<>no_Device then begin
    Anzeige_String:='RTC=';
    Geraete_anzeigen_Device(Device_List.RTC_Devive);
    CONOUT_WriteLn_String(Anzeige_String);



    CONOUT_WriteLn_String('Datum='+
                          ByteToHexStr(Date_and_Time_Vector[0])+'.'+
                          ByteToHexStr(Date_and_Time_Vector[1])+'.'+
                          ByteToHexStr(Date_and_Time_Vector[2])+
                          ByteToHexStr(Date_and_Time_Vector[3])+
                          '   Zeit='+
                          ByteToHexStr(Date_and_Time_Vector[4])+':'+
                          ByteToHexStr(Date_and_Time_Vector[5])+':'+
                          ByteToHexStr(Date_and_Time_Vector[6]) );



  end; // if RTC_Devive<>no_Device then



end; // Show_devices









function DISKNR_in_interface : Byte;
var
  Eintrag_Wert : Byte;
  Laufwerk_Word : Word;
begin

  if DISKNR<$80 then begin

    if DISKNR=0 then
      Eintrag_Wert:=Device_List.FDD_LW_A
    else
      Eintrag_Wert:=Device_List.FDD_LW_B;

  end
  else begin

    Laufwerk_Word:=ByteToWord(DISKNR);
    Laufwerk_Word:=Laufwerk_Word and $007F;

    Eintrag_Wert:=Device_List.HDD_table[Laufwerk_Word];

  end;

  Result:=Eintrag_Wert;

end; // DISKNR_in_interface






procedure Laufwerke_Verteiler_READ;
var
  Eintrag_Wert : Byte;
begin

    Eintrag_Wert:=DISKNR_in_interface;

    case Eintrag_Wert of

      Device_Serial : LBA_Sektor_von_UART_lesen;

      Device_ITP3_DS0 : begin
                          DEV_NR:=DEV_DS0;
                          ITP3_Sektor_lesen;
                        end;

      Device_ITP3_DS1 : begin
                          DEV_NR:=DEV_DS1;
                          ITP3_Sektor_lesen;
                        end;

      Device_ITP3_DS2 : begin
                          DEV_NR:=DEV_DS2;
                          ITP3_Sektor_lesen;
                        end;

      Device_ITP3_DS3 : begin
                          DEV_NR:=DEV_DS3;
                          ITP3_Sektor_lesen;
                        end;


    end; // case Eintrag_Wert of

end; // Laufwerke_Verteiler_READ;






procedure Laufwerke_Verteiler_WRITE;
var
  Eintrag_Wert : Byte;
begin

  Eintrag_Wert:=DISKNR_in_interface;

  case Eintrag_Wert of

      Device_Serial : LBA_Sektor_an_UART_schreiben;

      Device_ITP3_DS0 : begin
                          DEV_NR:=DEV_DS0;
                          ITP3_Sektor_schreiben;
                        end;

      Device_ITP3_DS1 : begin
                          DEV_NR:=DEV_DS1;
                          ITP3_Sektor_schreiben;
                        end;

      Device_ITP3_DS2 : begin
                          DEV_NR:=DEV_DS2;
                          ITP3_Sektor_schreiben;
                        end;

      Device_ITP3_DS3 : begin
                          DEV_NR:=DEV_DS3;
                          ITP3_Sektor_schreiben;
                        end;

    end; // case Eintrag_Wert of

end; // Laufwerke_Verteiler_WRITE;







procedure DevList_to_DevList_Vektor;
var
  DL_Zeiger : Word;
begin

  with Device_List do begin

    for DL_Zeiger:=0 to 15 do begin
      DevList_Vector[DL_Zeiger]:=HDD_table[DL_Zeiger];
    end;

    DevList_Vector[16]:=FDD_LW_A;
    DevList_Vector[17]:=FDD_LW_B;

    DevList_Vector[18]:=CONOUT_Device;
    DevList_Vector[19]:=CONIN_Device;
    DevList_Vector[20]:=LIST_Device;
    DevList_Vector[21]:=SOUND_Device;
    DevList_Vector[22]:=RTC_Devive;
    DevList_Vector[23]:=MOUSE_Device;

    for DL_Zeiger:=24 to 41 do begin
      DevList_Vector[DL_Zeiger]:=no_Device;
    end;

  end; { with DevList_Vektor do }

end; { procedure DevList_to_DevList_Vektor }








{$I DeviceManager_CPU8088.INC}

{$I DeviceManager_DOS_IO.INC}











procedure DEVICE_CONTROL;
begin


  // Fehlermeldungen bei fehlenden Geraeten/Devices

  if Device_List.CONOUT_Device=no_Device then begin
    UART_WriteLn_Text('y*** Fehler: kein Monitor angeschlossen!!! ***');
    LED_blinken;
  end; // if CONOUT_Device=no_Device then



  if Device_List.CONIN_Device=no_Device then begin
    CONOUT_WriteLn_String(chr(12));
    CONOUT_WriteLn_String('*** Fehler: keine Tastatur angeschlossen!!! ***');
    LED_blinken;
  end; // if CONIN_Device=no_Device then




  if Device_List.FDD_LW_A=no_Device then begin
    CONOUT_WriteLn_String(chr(12));
    CONOUT_WriteLn_String('*** Fehler: kein Laufwerk angeschlossen!!! ***');
    LED_blinken;
  end; // if FDD_Tabelle[0]=no_Device then



end; // procedure SET_BOOT_DRIVE







end.

