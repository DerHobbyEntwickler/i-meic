unit ITP3_SRV_U;
{$MODE OBJFPC}


interface

uses
  pico_gpio_c,

  SysUtils_U,
  GlobalDEF_U,
  GlobalHW_U;



  procedure ITP3_pruefe_Anschluesse;
  procedure ITP3_sende_VIDEO_SA;
  procedure ITP3_sende_VIDEO_SEND;
  procedure ITP3_empfange_VIDEO_GET;
  procedure ITP3_empfange_CONST;
  procedure ITP3_CONIN_Schleife;
  procedure ITP3_empfange_DATE_TIME;

  procedure ITP3_Sektor_schreiben;
  procedure ITP3_Sektor_lesen;




implementation




// ****************************
// *** ITP3-Server-Routinen ***
// *** Softwareteil         ***
// ****************************


CONST

  Wait_counter_max = 100000;



{

  Konfiguration WHO_ARE_YOU - Byte
  D7 - VIDEO
  D6 - KEYBOARD
  D5 - PRINT
  D4 - AUDIO
  D3 - FDD - 1.44MB
  D2 - HDD - 8MB
  D1 - RTC
  D0 - Uebertragsbyte vorhanden

}

  // Befehlscode fuer ITP3
  ITP3_WHO_ARE_YOU = 01;
  ITP3_OS_MARKER   = 02;

  ITP3_CONST       = 04;
  ITP3_CONIN       = 05;

  ITP3_RD_SEC      = 07;
  ITP3_WR_SEC      = 08;
  ITP3_AUDIO       = 09;

  ITP3_VIDEO_SEND  = 10;
  ITP3_VIDEO_GET   = 11;
  ITP3_VIDEO_SA    = 12;

  ITP3_VIDEO_SysTick = 14;

  ITP3_RTC         = 15;




  // Befehlscode fuer OS_MARKER
  OS_NN    = 00;
  OS_CPM   = 01;
  OS_DOS   = 02;
  OS_WIN   = 03;
  OS_LINUX = 04;



  // dieser ITP3-Modul ist ein
  // DOS-Modul !!!
  OS_Vorgabe = OS_DOS;






// *********************************************
// *********************************************
// ***  INIT_ITP3 - HW spezifischer Teil !!! ***
// *********************************************
// *********************************************



procedure DEV_NR_ClearBit;
begin

  case  DEV_NR of

    DEV_DS0 : // ClearBit(ITP3_DS0);
              gpio_put(TPicoPin.ITP3_DS0,false);

    DEV_DS1 : // ClearBit(ITP3_DS1);
              gpio_put(TPicoPin.ITP3_DS1,false);

    DEV_DS2 : // ClearBit(ITP3_DS2);
              gpio_put(TPicoPin.ITP3_DS2,false);

    DEV_DS3 : // ClearBit(ITP3_DS3);
              gpio_put(TPicoPin.ITP3_DS3,false);

  end;

end; // DEV_NR_ClearBit;





procedure DEV_NR_SetBit;
begin

  case  DEV_NR of

    DEV_DS0 : // SetBit(ITP3_DS0);
              gpio_put(TPicoPin.ITP3_DS0,true);

    DEV_DS1 : // SetBit(ITP3_DS1);
              gpio_put(TPicoPin.ITP3_DS1,true);

    DEV_DS2 : // SetBit(ITP3_DS2);
              gpio_put(TPicoPin.ITP3_DS2,true);

    DEV_DS3 : // SetBit(ITP3_DS3);
              gpio_put(TPicoPin.ITP3_DS3,true);

  end;

end; // DEV_NR_SetBit;




procedure ITP3_OUT_D0_bis_D3(H_Byte : Byte);
 begin
  // CB
  gpio_put(TPicoPin.ITP3_D0,((H_Byte and %00000001)<>0));
  gpio_put(TPicoPin.ITP3_D1,((H_Byte and %00000010)<>0));
  gpio_put(TPicoPin.ITP3_D2,((H_Byte and %00000100)<>0));
  gpio_put(TPicoPin.ITP3_D3,((H_Byte and %00001000)<>0));
end; // ITP3_OUT_D0_bis_D3





function ITP3_IN_D0_bis_D3 : Byte;
var
  Result_Byte : Byte;
begin

  // nun liegt das Halbbyte an und kann
  // in das Result_Byte eingelesen werden
  Result_Byte:=%00000000;

  // D0 einlesen
  if gpio_get(TPicoPin.ITP3_D0) then
    Result_Byte:=Result_Byte or %00000001;

  // D1 einlesen
  if gpio_get(TPicoPin.ITP3_D1) then
    Result_Byte:=Result_Byte or %00000010;

  // D2 einlesen
  if gpio_get(TPicoPin.ITP3_D2) then
    Result_Byte:=Result_Byte or %00000100;

  // D3 einlesen
  if gpio_get(TPicoPin.ITP3_D3) then
    Result_Byte:=Result_Byte or %00001000;

  Result:=Result_Byte;

end; // ITP3_IN_D0_bis_D3







// ****************************************************
// ****************************************************
// ***  ENDE - INIT_ITP3 - HW spezifischer Teil !!! ***
// ****************************************************
// ****************************************************









// Byte senden

procedure ITP3_sende_Halbbyte(H_Byte : Byte);
begin

  ITP3_OUT_D0_bis_D3(H_Byte);

  // jetzt wird dem Client mitgeteilt, das Daten fuer ihn anliegen
  DEV_NR_ClearBit;


  // CC
  // warten solange bis der Client die
  // Daten eingelesen hat und dies
  // bestaetigt hat
  // while BitHigh(ITP3_DR) do
  while BitHigh(TPicoPin.ITP3_DR) do begin
  end;


  // Client hat die Daten uebernommen,
  // die DS-Leitung wird wieder frei gegeben
  DEV_NR_SetBit;


  // warten solange, bis der Client die DR-Leitung
  // wieder frei gibt
  // while BitLow(ITP3_DR) do
  while BitLow(TPicoPin.ITP3_DR) do begin
  end;

end; // ITP3_sende_Halbbyte;





procedure ITP3_sende_Byte(SB : Byte);
begin

  // alle Datenleitungen auf Ausgang schalten
  ITP3_Daten_auf_Ausgang;

  // Steuerleitungen setzen
  DEV_NR_SetBit;    // DSX auf 1

  // senden des Low-Halbbyte
  ITP3_sende_Halbbyte(SB and %00001111);

  // senden des High-Halbbyte
  ITP3_sende_Halbbyte((SB shr 4) and %00001111);

  // alle Datenleitungen auf Eingang schalten
  ITP3_Daten_auf_Eingang;

end; // ITP3_sende_Byte;







// Test-Byte senden

function ITP3_sende_Test_Halbbyte(H_Byte : Byte) : Boolean;
var
  Wait_counter : DWord;
  Result_Byte : Boolean;
begin

  ITP3_OUT_D0_bis_D3(H_Byte);

  // jetzt wird dem Client mitgeteilt, das Daten fuer ihn anliegen
  DEV_NR_ClearBit;

  // warten solange der Client die Daten uebernimmt
  Wait_counter:=0;
  Result_Byte:=true;
  while Result_Byte do begin


    // if BitLow(ITP3_DR_E) then
    if BitLow(TPicoPin.ITP3_DR) then
      Result_Byte:=false;

    if Wait_counter>Wait_counter_max then
      Result_Byte:=false;

    Inc(Wait_counter);

  end; // while Result_Byte do


  // hat der Client reagiert, dann ist
  // der test erfolgreich
  // if BitLow(ITP3_DR_E) then
  if BitLow(TPicoPin.ITP3_DR) then begin


    // die DS-Leitung wird wieder frei gegeben
    DEV_NR_SetBit;


    Result_Byte:=true;

    // Client hat die Daten uebernommen,

    // warten solange, bis der Client die DR-Leitung
    // wieder frei gibt
    while BitLow(TPicoPin.ITP3_DR) do begin
    end;

  end
  else begin

    // die DS-Leitung wird wieder frei gegeben
    DEV_NR_SetBit;

    Result_Byte:=false;

  end; // if (PIND and %10000000)=0 then

  Result:=Result_Byte;

end; // ITP3_sende_Test_Halbbyte;





function ITP3_sende_Test_Byte(SB : Byte) : Boolean;
var
  b1 : Byte;
  Result_Byte : Boolean;
begin

  // alle Datenleitungen auf Ausgang schalten
  ITP3_Daten_auf_Ausgang;


  // Steuerleitungen setzen
  DEV_NR_SetBit;    // DSX auf 1


  // senden des Low-Halbbyte
  Result_Byte:=ITP3_sende_Test_Halbbyte(SB and %00001111);


  if Result_Byte then begin

    // senden des High-Halbbyte
    ITP3_sende_Halbbyte((SB shr 4) and %00001111);

  end; // if Result_Byte then


  // alle Datenleitungen auf Eingang schalten
  ITP3_Daten_auf_Eingang;

  Result:=Result_Byte;

end; // ITP3_sende_Test_Byte;
















// Byte empfangen

function ITP3_empfange_Halbbyte : Byte;
var
  Result_Byte : Byte;
begin

  // SA

  // nun wird dem Client durch Aktivierung
  // der DSX-Leitung mitgeteilt,
  // dass der Server das naechste Halbbyte
  // empfangen kann
  DEV_NR_ClearBit;

  // SB

  // warten, solange bis der Client das
  // Halbbyte bereit stellt
  // while BitHigh(ITP3_DR_E) do
  while BitHigh(TPicoPin.ITP3_DR) do begin
  end;


  // SC
  Result_Byte:=ITP3_IN_D0_bis_D3;


  // SD

  // jetzt wird dem Client mitgeteilt,
  // das der Server das Halbbyte
  // uebernommen hat
  DEV_NR_SetBit;


  // SE

  // warten solange bis der Client die
  // Bestaetigung angenommen hat
  // while BitLow(ITP3_DR_E) do
  while BitLow(TPicoPin.ITP3_DR) do begin
  end;


  // SF

  Result:=Result_Byte;

end; // ITP3_empfange_Halbbyte;






function ITP3_empfange_Byte : Byte;
var
  Result_Byte_01 : Byte;
  Result_Byte_02 : Byte;
begin

  // alle Datenleitungen auf Eingang schalten
  ITP3_Daten_auf_Eingang;

  // DS auf High (Grundzustand)
  DEV_NR_SetBit;

  // unteres Halbbyte
  Result_Byte_01:=ITP3_empfange_Halbbyte;

  // oberes Halbbyte
  Result_Byte_02:=ITP3_empfange_Halbbyte;


  // DR wieder auf Eingang fuer die anderen Clients
 // gpio_set_dir(TPicoPin.ITP3_DR,TGPIODirection.GPIO_IN);

  Result_Byte_01:=Result_Byte_01+(Result_Byte_02 shl 4);

  Result:=Result_Byte_01;

end; // ITP3_empfange_Byte;








// ****************************
// *** ITP3-Server-Routinen ***
// *** Softwareteil - 2 -   ***
// ****************************







procedure ITP3_empfange_DATE_TIME;
var
  TIME_Vektor_Zeiger : Word;
  ein_Byte : Byte;
begin

  ITP3_sende_Byte(ITP3_RTC);

  // 04 04 20 24 19 24 56
  //  0  1  2  3  4  5  6
  for TIME_Vektor_Zeiger:=0 to 6 do begin
    ein_Byte:=ITP3_empfange_Byte;
    Date_and_Time_Vector[TIME_Vektor_Zeiger]:=ein_Byte;
  end;

end; // ITP3_empfange_DATE_TIME






procedure ITP3_sende_VIDEO_SA;
var
  ein_Byte : Byte;
  SP_Zeiger : Word;
begin

  ITP3_sende_Byte(ITP3_VIDEO_SA);

  // senden von 1 + 20 Bytes SA (Spalten_Abschnitt) an ITP3
  for SP_Zeiger:=0 to 20 do begin
    ein_Byte:=Sektor_Puffer[SP_Zeiger];
    ITP3_sende_Byte(ein_Byte);
  end; { for Sektor_Puffer_Zeiger:=0 to 20 do }

end; // ITP3_sende_VIDEO_SA;




procedure ITP3_sende_VIDEO_SEND;
begin

  ITP3_sende_Byte(ITP3_VIDEO_SEND);
  ITP3_sende_Byte(VIDEO_SEND_Routine);
  ITP3_sende_Byte(VIDEO_SEND_Param1);
  ITP3_sende_Byte(VIDEO_SEND_Param2);

end; // ITP3_sende_VIDEO_SEND;





procedure ITP3_empfange_VIDEO_GET;
begin

  ITP3_sende_Byte(ITP3_VIDEO_GET);
  ITP3_sende_Byte(VIDEO_GET_Routine);
  VIDEO_GET_Param1:=ITP3_empfange_Byte;
  VIDEO_GET_Param2:=ITP3_empfange_Byte;

end; // ITP3_empfange_VIDEO_GET;







procedure ITP3_empfange_CONST;
begin

  ITP3_sende_Byte(ITP3_CONST);
  ConsoleStat:=ITP3_empfange_Byte;

end; // ITP3_empfange_CONST;






procedure ITP3_empfange_CONIN;
var
  ein_Byte : Byte;
  ein_Word : Word;
begin

  ITP3_sende_Byte(ITP3_CONIN);

  ein_Byte:=ITP3_empfange_Byte;

  ein_Word:=ByteToWord(ein_Byte);
  ein_Word:=ein_Word shl 8;

  ConsoleIn:=ein_Word;

  ein_Byte:=ITP3_empfange_Byte;
  ein_Word:=ein_Byte;

  ConsoleIn:=ConsoleIn+ein_Word;

end; // ITP3_empfange_CONIN;







procedure ITP3_CONIN_Schleife;
begin

  ITP3_empfange_CONST;

  while ConsoleStat<100 do begin
    ITP3_empfange_CONST;
  end;

  ITP3_empfange_CONIN;

end; // ITP3_CONIN_Schleife;





// ***********************
// ITP3 - Laufwerk
// ***********************



procedure ITP3_Sektor_lesen;
var
  READ_Byte : Byte;
  SP_Zeiger : Word;
  // s1 : String;
begin

  ITP3_sende_Byte(ITP3_RD_SEC);

  READ_Byte:=HI(DISK_LBA);
  ITP3_sende_Byte(READ_Byte);

  READ_Byte:=LO(DISK_LBA);
  ITP3_sende_Byte(READ_Byte);

  ITP3_sende_Byte(DISKNR);

  for SP_Zeiger:=0 to 511 do begin
    READ_Byte:=ITP3_empfange_Byte;
    Sektor_Puffer[SP_Zeiger]:=READ_Byte;
  end;

end; // ITP3_Sektor_lesen;







procedure ITP3_Sektor_schreiben;
var
  WRITE_Byte : Byte;
  SP_Zeiger : Word;
begin

  ITP3_sende_Byte(ITP3_WR_SEC);

  WRITE_Byte:=HI(DISK_LBA);
  ITP3_sende_Byte(WRITE_Byte);
  WRITE_Byte:=LO(DISK_LBA);
  ITP3_sende_Byte(WRITE_Byte);
  ITP3_sende_Byte(DISKNR);

  for SP_Zeiger:=0 to 511 do begin

    WRITE_Byte:=Sektor_Puffer[SP_Zeiger];
    ITP3_sende_Byte(WRITE_Byte);

  end;

end; // ITP3_Sektor_schreiben;









// ***********************
// ITP3 - Anschlussabfrage
// ***********************



function ITP3_DEV_zu_Device : Byte;
var
  CON_Device : Byte;
begin

  case DEV_NR of

    DEV_DS0 : CON_Device:=Device_ITP3_DS0;

    DEV_DS1 : CON_Device:=Device_ITP3_DS1;

    DEV_DS2 : CON_Device:=Device_ITP3_DS2;

    DEV_DS3 : CON_Device:=Device_ITP3_DS3;

  else

    CON_Device:=no_Device;

  end;

  Result:=CON_Device;

end; // ITP3_DEV_zu_Device;









procedure ITP3_Abfrage_WHO_ARE_YOU;
var
  ok_Byte : Boolean;
  WHO_ARE_YOU_Byte : Byte;
  b1 : Byte;
begin


  ok_Byte:=ITP3_sende_Test_Byte(ITP3_WHO_ARE_YOU);


  if ok_Byte then begin

    WHO_ARE_YOU_Byte:=ITP3_empfange_Byte;


    // *** Byte 7 ***
    // VIDEO (CONOUT)
    b1:=WHO_ARE_YOU_Byte and %10000000;

    if b1>0 then
      Device_List.CONOUT_Device:=ITP3_DEV_zu_Device;


    // *** Byte 6 ***
    // KEYBOARD (CONIN)
    b1:=WHO_ARE_YOU_Byte and %01000000;

    if b1>0 then
      Device_List.CONIN_Device:=ITP3_DEV_zu_Device;


    // *** Byte 5 ***
    // PRINT
    b1:=WHO_ARE_YOU_Byte and %00100000;

    if b1>0 then
      Device_List.LIST_Device:=ITP3_DEV_zu_Device;


    // *** Byte 4 ***
    // AUDIO
    b1:=WHO_ARE_YOU_Byte and %00010000;

    if b1>0 then
      Device_List.SOUND_Device:=ITP3_DEV_zu_Device;


    // *** Byte 3 ***
    // FDD - 1.44MB
    b1:=WHO_ARE_YOU_Byte and %00001000;

    if b1>0 then begin

      case DEV_NR of

        DEV_DS0 : FDD_Tabelle[0]:=Device_ITP3_DS0;

        DEV_DS1 : FDD_Tabelle[1]:=Device_ITP3_DS1;

        DEV_DS2 : FDD_Tabelle[2]:=Device_ITP3_DS2;

        DEV_DS3 : FDD_Tabelle[3]:=Device_ITP3_DS3;

      end; // case DEV_NR of

      FDD_ITP3_available:=true;

    end; // if b1>0 then


    // *** Byte 2 ***
    // HDD 8MB
    b1:=WHO_ARE_YOU_Byte and %00000100;

    if b1>0 then begin

      case DEV_NR of

        DEV_DS0 : Device_List.HDD_table[0]:=Device_ITP3_DS0;

        DEV_DS1 : Device_List.HDD_table[1]:=Device_ITP3_DS1;

        DEV_DS2 : Device_List.HDD_table[2]:=Device_ITP3_DS2;

        DEV_DS3 : Device_List.HDD_table[3]:=Device_ITP3_DS3;

      end; // case DEV_NR of

    end; // if b1>0 then


    // *** Byte 1 ***
    // RTC (TIMER)
    b1:=WHO_ARE_YOU_Byte and %00000010;

    if b1>0 then
      Device_List.RTC_Devive:=ITP3_DEV_zu_Device;


  end;  // if ok_Byte then


end; // ITP3_Abfrage_WHO_ARE_YOU;










procedure ITP3_pruefe_einen_Anschluss;
var
  ok_Byte : Boolean;
  OS_Marker_Byte : Byte;
begin

  ok_Byte:=ITP3_sende_Test_Byte(ITP3_OS_MARKER);

  // wurde ITP3_sende_Test_Byte an diesem Port erkannt,
  // dann ist ok_Byte=true
  if ok_Byte then begin

    // ist die ITP3-Schnittstelle aktiv,
    // kann der OS_Marker abgefragt werden
    OS_Marker_Byte:=ITP3_empfange_Byte;

    // ist der OS_Marker = der OS_Vorgabe, d.h.
    if OS_Marker_Byte=OS_Vorgabe then begin

      ITP3_Abfrage_WHO_ARE_YOU;

    end
    else begin

      // Abspeichern des erkannten OS ist
      // derzeit nicht genutzt

    end;

  end;  // if ok_Byte then

end; // ITP3_pruefe_einen_Anschluss;






procedure ITP3_pruefe_Anschluesse;
begin

  // 1. Durchlauf
  DEV_NR:=DEV_DS0;
  ITP3_pruefe_einen_Anschluss;

  DEV_NR:=DEV_DS1;
  ITP3_pruefe_einen_Anschluss;

  DEV_NR:=DEV_DS2;
  ITP3_pruefe_einen_Anschluss;

  DEV_NR:=DEV_DS3;
  ITP3_pruefe_einen_Anschluss;



  // 2. Durchlauf

  DEV_NR:=DEV_DS0;
  ITP3_pruefe_einen_Anschluss;

  DEV_NR:=DEV_DS1;
  ITP3_pruefe_einen_Anschluss;

  DEV_NR:=DEV_DS2;
  ITP3_pruefe_einen_Anschluss;

  DEV_NR:=DEV_DS3;
  ITP3_pruefe_einen_Anschluss;



  // 3. Durchlauf

  DEV_NR:=DEV_DS0;
  ITP3_pruefe_einen_Anschluss;

  DEV_NR:=DEV_DS1;
  ITP3_pruefe_einen_Anschluss;

  DEV_NR:=DEV_DS2;
  ITP3_pruefe_einen_Anschluss;

  DEV_NR:=DEV_DS3;
  ITP3_pruefe_einen_Anschluss;




  // wichtig !!!
  Copy_FDD_table_downwards;
  Copy_HDD_table_downwards;


  if FDD_Serial_available then begin

    Device_List.FDD_LW_A:=Device_Serial;
    if FDD_Tabelle[0]<>no_Device then
      Device_List.FDD_LW_B:=FDD_Tabelle[0];

  end
  else begin
    Device_List.FDD_LW_A:=FDD_Tabelle[0];
  end;


  if HDD_Serial_available then begin
    Copy_HDD_table_upwards;
    Device_List.HDD_table[0]:=Device_Serial;
    Copy_HDD_table_downwards;
  end;


end; // ITP3_pruefe_Anschluesse;





end. // ITP3_SRV_U


