unit UART_U;
{$MODE OBJFPC}


interface

uses

  pico_c,
  pico_uart_c,

  GlobalDEF_U,
  GlobalHW_U,
  SysUtils_U;






  procedure INIT_Serial;

  procedure UART_WriteLn_Text(Text : STRING);

  function CONST_von_UART_lesen : Byte;
  procedure UART_CONIN_loop;

  procedure Maus_von_UART_lesen;
  procedure UART_Maus_INIT_ON_OFF(Maus_PRG : Char);

  procedure Write_VIDEO_SA_an_UART_senden;
  procedure VIDEO_SEND_an_UART_senden;
  procedure VIDEO_GET_von_UART_lesen;
  procedure LBA_Sektor_von_UART_lesen;
  procedure LBA_Sektor_an_UART_schreiben;
  procedure DEBUG_an_UART_senden;

  procedure Datum_und_Zeit_von_UART_lesen;
  procedure IO_Wert_ERROR_an_UART_senden(IO_Wert : Byte);

  procedure DEVICE_VECTOR_von_UART_lesen_und_auswerten;


implementation


  VAR

    Steuer_String : STRING;

    DEVICE_VECTOR_read,
    ConsoleIn_read,
    ConsoleStat_read,
    VIDEO_PARAMETER_read,
    Mouse_Parameter_read : Boolean;

    Date_set : Boolean;

    Sektor_Puffer_Zeiger : Word;







  procedure UART_Write_Text(Text : STRING);
  var
    UW_Zaehler : Integer;
  begin
    for UW_Zaehler:=1 to Length(Text) do
      UART_Write_Zeichen(Text[UW_Zaehler]);

  end; // UART_Write_Text




  procedure UART_WriteLn_Text(Text : STRING);
  begin
    UART_Write_Text(Text);
    UART_Write_Zeichen(CHR($0D));
    UART_Write_Zeichen(CHR($0A));
  end; // UART_WriteLn_Text






  procedure INIT_DEBUG_array;
  var
    w1 : Word;
    b2 : Byte;
  begin

    b2:=5;
    for w1:=0 to 20 do begin
      DEBUG_array[w1]:=b2;
      INC(b2);
    end; { for b1:=0 to 7 do }

  end; // INIT_DEBUG_array






  // liest die Bytes aus der SteuerString in den Sektor_Puffer
  procedure Steuer_String_To_Sector;
  var
    b1 : Byte;
    b2 : Byte;
    b3 : Byte;
  begin
    b2:=2;
    for b1:=0 to 15 do begin
      b3:=HexStrToByte(Steuer_String[b2]+Steuer_String[b2+1]);
      Inc(b2); Inc(b2);
      Sektor_Puffer[Sektor_Puffer_Zeiger]:=b3;
      Inc(Sektor_Puffer_Zeiger);
    end;

  end; // Steuer_String_To_Sector;









  // liest die Bytes aus der SteuerString in den DATE und TIME-Puffer
  procedure Steuer_String_To_TIME;
  var
    ein_Byte : Byte;
    SS_Zaehler : Byte;
    TIME_Vector_counter : Word;
  begin

    SS_Zaehler:=2;

    // D04042024192456
    //   0 1 2 3 4 5 6
    for TIME_Vector_counter:=0 to 6 do begin
      ein_Byte:=HexStrToByte(Steuer_String[SS_Zaehler]+Steuer_String[SS_Zaehler+1]);
      Date_and_Time_Vector[TIME_Vector_counter]:=ein_Byte;
      INC(SS_Zaehler); INC(SS_Zaehler);
    end;

    Date_set:=true;

  end; // Steuer_String_To_TIME;






  // **********************************************





  procedure Steuer_String_evaluate;
  var
    Buchstabe : Char;
    Laenge : Byte;
  begin
    Laenge:=Length(Steuer_String);

    if Laenge>0 then begin
      Buchstabe:=Steuer_String[1];
      case Buchstabe of



        // GP1P2 1+2+2 VIDEO_PARAMETER Empfangen
        'G' : begin
                if Laenge=5 then begin
                  VIDEO_GET_Param1:=HexStrToByte(Steuer_String[2]+Steuer_String[3]);
                  VIDEO_GET_Param2:=HexStrToByte(Steuer_String[4]+Steuer_String[5]);

                  VIDEO_PARAMETER_read:=true;
                end
                else
                  UART_WriteLn_Text('x20');

              end; // 'G'



              // HC0 2+1 Empfangen des DEVICE_VECTOR vom PC an den Mikrocontrollers
        'H' : begin
                if Laenge=3 then begin
                  DEVICE_VECTOR_Byte:=HexStrToByte(Steuer_String[2]+Steuer_String[3]);
                  DEVICE_VECTOR_read:=true;
                end
                else
                  UART_WriteLn_Text('x21');

              end; // 'H'



              // I1E61 1+2+2 Senden eines Zeichens an CONIN des Mikrocontrollers
        'I' : begin
                if Laenge=5 then begin
                  ConsoleIn:=HexStrToWord(Steuer_String[2]+Steuer_String[3]+
                                             Steuer_String[4]+Steuer_String[5]);
                  ConsoleIn_read:=true;
                end
                else
                  UART_WriteLn_Text('x22');

              end; // 'I'


              // JFF 1+2 Senden eines Zeichens an CONST des Mikrocontrollers
        'J' : begin
                if Laenge=3 then begin
                  ConsoleStat:=HexStrToByte(Steuer_String[2]+Steuer_String[3]);
                  ConsoleStat_read:=true;
                end
                else
                  UART_WriteLn_Text('x23');

              end; // 'J'


              // AD0D1D2D3D4D5D6D7D8D9DADBDCDDDEDF  1+(16*2)
        'A' : begin
                if Laenge=33 then begin // ein Sektor-Abschnitt
                  Steuer_String_To_Sector;
                end
                else
                  UART_WriteLn_Text('x24');

              end; // 'A'


              // D329B133357 = D + Datum(8) + Zeit(6) = 15
        'D' : begin
                if Laenge=15 then begin
                  Steuer_String_To_TIME;
                end
                else
                  UART_WriteLn_Text('x25');

              end; // 'D'




              // N BT XXXX YYYY 1+2+4+4=11 Abfrage der Maus-Parameter
        'N' : begin
                if Laenge=11 then begin
                  RMouse.Button:=HexStrToByte(Steuer_String[2]+Steuer_String[3]);
                  RMouse.X:=HexStrToWord(Steuer_String[4]+Steuer_String[5]+
                                            Steuer_String[6]+Steuer_String[7]);
                  RMouse.Y:=HexStrToWord(Steuer_String[8]+Steuer_String[9]+
                                            Steuer_String[10]+Steuer_String[11]);

                  Mouse_Parameter_read:=true;
                end
                else
                  UART_WriteLn_Text('x33');

              end; // 'N'



      else
        UART_WriteLn_Text('x26');
      end;

    end; { if Laenge>0 then }



  end; // Steuer_String_auswerten




  procedure Steuer_String_read;
  var
    akt_Zeichen : Char;
    empf_Zeichen : Byte;
  begin

 //   if UART_Zeichen_lesbar then begin

    empf_Zeichen:=UART_Read_ein_Byte;

    if empf_Zeichen<>$0D then begin // 0D wird ignoriert

      if empf_Zeichen=$0A then begin // bei 0A wird ausgerwertet
        Steuer_String_evaluate;
        Steuer_String:='';
      end
      else begin
        akt_Zeichen:=ByteToChar(empf_Zeichen);
        Steuer_String:= Steuer_String + akt_Zeichen; // sonst nur abgespeichert
      end; { if akt_Zeichen<>char($0A) }

    end; { if akt_Zeichen<>char($0D) then }

  //  end;

  end; // Steuer_String_read






  // **********************************************







  procedure Datum_und_Zeit_von_UART_lesen;
  var
    Read_Loop : DWord;
  begin

    UART_WriteLn_Text('d');

    Date_set:=false;

    Read_Loop:=500000;

    while Read_Loop>5 do begin

      if UART_Zeichen_lesbar then begin

          Steuer_String_read;

          if Date_set then
            Read_Loop:=2  // Ende
          else
            Read_Loop:=500000;

      end;

      Dec(Read_Loop);

    end;

    if Read_Loop>2 then
      UART_WriteLn_Text('x22');


  end; // Datum_und_Zeit_von_UART_lesen;






  procedure Maus_von_UART_lesen;
  var
    Read_Loop : DWord;
  begin

    UART_WriteLn_Text('nr');

    Mouse_Parameter_read:=false;

    Read_Loop:=500000;

    while Read_Loop>5 do begin

      if UART_Zeichen_lesbar then begin

          Steuer_String_read;

          if Mouse_Parameter_read then
            Read_Loop:=2  // Ende
          else
            Read_Loop:=500000;

      end;

      Dec(Read_Loop);

    end;

    if Read_Loop>2 then
      UART_WriteLn_Text('x32');


  end; // procedure Maus_von_UART_lesen







  procedure UART_Maus_INIT_ON_OFF(Maus_PRG : Char);
  begin

    UART_WriteLn_Text('n'+Maus_PRG);

  end; // procedure UART_Maus_Parameter_setzen










  procedure LBA_Sektor_von_UART_lesen;
  begin

      // r HI_LBA LO_LBA DISKNO = 4 Byte
      UART_WriteLn_Text('r'+
        ByteToHexStr(HighWordToByte(DISK_LBA))+
        ByteToHexStr(LowWordToByte(DISK_LBA))+
        ByteToHexStr(DISKNR));

      UART_Read_Sector;

  end; // LBA_Sektor_von_UART_lesen;




  procedure LBA_Sektor_an_UART_schreiben;
  var
    b1 : Byte;
    b2 : Byte;
    b3 : Byte;
    LBA_String : STRING;
  begin


    // w HI_LBA LO_LBA DISKNO = 4 Byte
    UART_WriteLn_Text('w'+
      ByteToHexStr(HighWordToByte(DISK_LBA))+
      ByteToHexStr(LowWordToByte(DISK_LBA))+
      ByteToHexStr(DISKNR));

    Sektor_Puffer_Zeiger:=0;

    // b CNT D0 D1 ... D15
    for b1:=0 to 31 do begin

      LBA_String:='b'+ByteToHexStr(b1);

      for b2:=0 to 15 do begin
        b3:=Sektor_Puffer[Sektor_Puffer_Zeiger];
        Inc(Sektor_Puffer_Zeiger);
        LBA_String:=LBA_String+ByteToHexStr(b3);
      end; { for b2:=0 to 15 do }

      UART_WriteLn_Text(LBA_String);

    end; { for b1:=0 to 7 do }


  end; // LBA_Sektor_an_UART_schreiben;






  // **********************************************







  procedure DEVICE_VECTOR_von_UART_lesen;
  var
    Read_Loop : DWord;
  begin

    DEVICE_VECTOR_Byte:=0;

    UART_WriteLn_Text('h');

    Read_Loop:=500000;
    DEVICE_VECTOR_read:=false;

    while Read_Loop>5 do begin

      if UART_Zeichen_lesbar then begin

        Steuer_String_read;

        if DEVICE_VECTOR_read then
          Read_Loop:=2  // Ende
        else
          Read_Loop:=500000;

      end; // if uart_is_readable(uart) then

      Dec(Read_Loop);

    end; // while LeseSchleife>5 do

    if Read_Loop>2 then
      UART_WriteLn_Text('x28');

  end; // DEVICE_VECTOR_von_UART_lesen;






  // **********************************************







  function CONST_von_UART_lesen : Byte;
  var
    Read_Loop : DWord;
  begin

    UART_WriteLn_Text('j');

    Read_Loop:=500000;
    ConsoleStat_read:=false;


    while Read_Loop>5 do begin

      if UART_Zeichen_lesbar then begin

        Steuer_String_read;

        if ConsoleStat_read then
          Read_Loop:=2  // Ende
        else
          Read_Loop:=500000;

      end; // if uart_is_readable(uart) then

      Dec(Read_Loop);

    end; // while LeseSchleife>5 do

    if Read_Loop>2 then
      UART_WriteLn_Text('x29');

    Result:=ConsoleStat;

  end; // CONST_von_UART_lesen;





  procedure CONIN_von_UART_lesen;
  var
    Read_Loop : DWord;
  begin

    UART_WriteLn_Text('i');

    Read_Loop:=500000;
    ConsoleIn_read:=false;

    while Read_Loop>5 do begin

      if UART_Zeichen_lesbar then begin

        Steuer_String_read;

        if ConsoleIn_read then
          Read_Loop:=2  // Ende
        else
          Read_Loop:=500000;

      end; // if uart_is_readable(uart) then

      Dec(Read_Loop);

    end; // while LeseSchleife>5 do

    if Read_Loop>2 then
      UART_WriteLn_Text('x30');

  end; // CONIN_von_UART_lesen;





  procedure UART_CONIN_loop;
  begin

    ConsoleStat:=0;

    while ConsoleStat=0 do
      CONST_von_UART_lesen;

    CONIN_von_UART_lesen;

  end; // UART_CONIN_Schleife;





  // **********************************************




  procedure DEBUG_an_UART_senden;
  var
    w1 : Word;
    b2 : Byte;
    DBG_String : STRING;
  begin

    DBG_String:='m';

    for w1:=0 to 18 do begin
      b2:=DEBUG_array[w1];
      DBG_String:=DBG_String+ByteToHexStr(b2);
    end; { for b1:=0 to 7 do }

    UART_WriteLn_Text(DBG_String);

  end; // DEBUG_an_UART_senden;






  // ******************************************




  {
   SA 01 02 03 .. 20
  }
  procedure Write_VIDEO_SA_an_UART_senden;
  var
    ein_Byte : Byte;
    SA_String : STRING;
  begin

    SA_String:='q';

    for Sektor_Puffer_Zeiger:=0 to 20 do begin
      ein_Byte:=Sektor_Puffer[Sektor_Puffer_Zeiger];
      SA_String:=SA_String+ByteToHexStr(ein_Byte);
    end; { for b2:=1 to 20 do }

    UART_WriteLn_Text(SA_String);


  end; // Write_VIDEO_SA_an_UART_senden;






  procedure VIDEO_SEND_an_UART_senden;
  begin

    UART_WriteLn_Text('f'+ByteToHexStr(VIDEO_SEND_Routine)+
                          ByteToHexStr(VIDEO_SEND_Param1)+
                          ByteToHexStr(VIDEO_SEND_Param2));

  end; // VIDEO_SEND_an_UART_senden;






  procedure VIDEO_GET_von_UART_lesen;
  var
    Read_Loop : DWord;
  begin

    UART_WriteLn_Text('g'+ByteToHexStr(VIDEO_GET_Routine));

    Read_Loop:=500000;
    VIDEO_PARAMETER_read:=false;

    while Read_Loop>5 do begin

      if UART_Zeichen_lesbar then begin

        Steuer_String_read;

        if VIDEO_PARAMETER_read then begin
          Read_Loop:=2;  // Ende
        end
        else begin
          Read_Loop:=500000;
        end; { if Datum_gesetzt then }

      end;

      Dec(Read_Loop);

    end;

    if Read_Loop>2 then
      UART_WriteLn_Text('x31');

  end; // VIDEO_GET_von_UART_lesen;





  // **********************************************



  //
  procedure IO_Wert_ERROR_an_UART_senden(IO_Wert : Byte);
  begin

    UART_WriteLn_Text('y*** OUT-Befehl ERROR -> IO_Wert='+
                      ByteToHexStr(IO_Wert)+'H');

  end; // IO_Wert_ERROR_an_UART_senden;





  // **********************************************



  procedure Warten_auf_Tastendruck;
  begin

    UART_WriteLn_Text('yWarten auf Tastendruck ...');
    UART_CONIN_loop;
    UART_WriteLn_Text('yConsoleIn='+ByteToHexStr(ConsoleIn)+'H');

  end; // procedure Warten_auf_Tastendruck




  // **********************************************



  procedure Abfrage_Serial_Device_connected;
  var
    empf_Zeichen : Byte;
  begin

    Serial_Device_connected:=false;

    UART_Write_Zeichen(#0);

    wait_ms(100);

    if UART_Zeichen_lesbar then begin

      empf_Zeichen:=UART_Read_ein_Byte;

      // PC mit USB-Serial angeschlossen
      if empf_Zeichen=xon then begin
        Serial_Device_connected:=true;
      end;

      // RPI angeschlossen
      if empf_Zeichen=xoff then begin
        Serial_Device_connected:=true;
      end;

    end; // if UART_Zeichen_lesbar then


    if Serial_Device_connected then
      UART_WriteLn_Text('ySerial_Device_connected=true')
    else
      UART_WriteLn_Text('ySerial_Device_connected=false  empf_Zeichen='+
                        ByteToHexStr(empf_Zeichen)+'H');


  end; // Abfrage_Serial_Device_connected;










  procedure Serial_DEVICE_VECTOR_auswerten;
  var
    b1 : Byte;
  begin


    // VIDEO
    b1:=DEVICE_VECTOR_Byte and %10000000;

    if b1>0 then begin

      if Device_List.CONOUT_Device=no_Device then begin
        Device_List.CONOUT_Device:=Device_Serial;
      end;

    end; // if b1>0 then



    // CONIN
    b1:=DEVICE_VECTOR_Byte and %01000000;

    if b1>0 then begin
      Device_List.CONIN_Device:=Device_Serial;
    end;


    // LIST
    b1:=DEVICE_VECTOR_Byte and %00100000;

    if b1>0 then begin
      Device_List.LIST_Device:=Device_Serial;
    end;


    // SOUND
    b1:=DEVICE_VECTOR_Byte and %00010000;

    if b1>0 then begin
      Device_List.SOUND_Device:=Device_Serial;
    end;


    // FDD
    b1:=DEVICE_VECTOR_Byte and %00001000;

    if b1>0 then begin

      FDD_Serial_available:=true;

    end; // if b1>0 then



    // HDD
    b1:=DEVICE_VECTOR_Byte and %00000100;

    if b1>0 then begin

      HDD_Serial_available:=true;

    end; // if b1>0 then



    // RTC
    b1:=DEVICE_VECTOR_Byte and %00000010;

    if b1>0 then begin

      Device_List.RTC_Devive:=Device_Serial;

    end; // if b1>0 then



  end; // Serial_DEVICE_VECTOR_auswerten







  procedure DEVICE_VECTOR_von_UART_lesen_und_auswerten;
  begin

    // WHO_ARE_YOU Abfrage ueber DEVICE_VECTOR
    DEVICE_VECTOR_von_UART_lesen;

    Serial_DEVICE_VECTOR_auswerten;

    UART_WriteLn_Text('ymit USB-Serial verbunden ...');

  end; // procedure DEVICE_VECTOR_von_UART_lesen_und_auswerten





  procedure INIT_Serial;
  begin

    ConsoleIn:=0;
    ConsoleStat:=0;
    ConsoleOut.Attribute:=$07;
    ConsoleOut.Character:=$20;
    ConsoleIn_read:=false;
    ConsoleStat_read:=false;

    Mouse_Parameter_read:=false;

    DEVICE_VECTOR_read:=false;


    Steuer_String:='';

    INIT_DEBUG_array;


    // 2. Start Serial
    Abfrage_Serial_Device_connected;
    UART_Write_Zeichen('@');
    Abfrage_Serial_Device_connected;


    if Serial_Device_connected then begin
      DEVICE_VECTOR_von_UART_lesen_und_auswerten;
    end;

  end; // procedure INIT_Serial







end. // UART_unit


