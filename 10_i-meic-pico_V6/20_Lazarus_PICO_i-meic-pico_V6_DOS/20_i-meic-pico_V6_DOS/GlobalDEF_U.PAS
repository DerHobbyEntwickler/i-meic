unit GlobalDEF_U;
{$MODE OBJFPC}


interface


const
    {
  BIOS_Segment=$FE00;
  BIOS_Seg_Byte=$FE;
       }
  BIOS_Segment=$F800;
  BIOS_Seg_Byte=$F8;


type

  T_ConsoleOut = record
                   Attribute, Character : Byte;
                 end;


  T_BIOS_REC = record
                 BIOS_CODE : Word;
                 BOOT_DRIVE : Byte;
               end;


  TMouse = record
             Button : Byte;
             X, Y : Word;
           end;


  T_DEV_LST_REC = record
                    HDD_table : Array [0..15] of Byte;
                    FDD_LW_A, FDD_LW_B : Byte;
                    CONOUT_Device, CONIN_Device,
                    LIST_Device, SOUND_Device,
                    RTC_Devive, MOUSE_Device : Byte;
                    Reserve : Array [0..17] of Byte; // 18 Byte als Reserve
                  end;



var
  BIOS_REC : T_BIOS_REC;
  RMouse : TMouse;




CONST

  // System Konstanten

  no_Device          = 00;
  Device_Serial      = 01;

//  Device_lokal_Flash = 02;

  Device_ITP3_DS0    = 10;
  Device_ITP3_DS1    = 11;
  Device_ITP3_DS2    = 12;
  Device_ITP3_DS3    = 13;






  // 01..99 -> SEND 2 PARAM
  // Funktionen, die 2 Parameter an das VIDEO-Terminal senden
  VIDEO_CONOUT          : Byte = 06;




CONST

    nul  : Byte = $00;
    xon  : Byte = $11;
    xoff = $13;

    CR   : Byte = $0D;
    LF   : Byte = $0A;
    ESC  : Byte = $1B;




    // Befehlscode fuer OS_MARKER
    OS_NN      = 00;
    OS_CPM     = 01;
    OS_DOS     = 02;
    OS_WIN     = 03;
    OS_LINUX   = 04;



    // dieser ITP3-Modul ist ein
    // DOS-Modul !!!
    OS_Vorgabe : Byte = OS_DOS;




    BOOT_DRIVE_no          = 00;
    BOOT_DRIVE_Serial      = 01;
    BOOT_DRIVE_lokal_Flash = 02;
    BOOT_DRIVE_ITP3        = 03;



    // ITP3 DEVs
    DEV_DS0 = 00;
    DEV_DS1 = 01;
    DEV_DS2 = 02;
    DEV_DS3 = 03;
    DEV_DS4 = 04;
    NO_DEV  = 255;



    // OFFSET_A
    OFFSET_A0 = $000000;
    OFFSET_A1 = $168000;
    OFFSET_A2 = $2D0000;



VAR

  DEV_NR : Byte;

  // alle erkannten Geraete in einer Liste
  Device_List : T_DEV_LST_REC;

  // temporaere FDD-Tabelle
  FDD_Tabelle : Array [0..15] of Byte;


  FDD_Serial_available : Boolean;
//  FDD_lokal_Flash_available : Boolean;
  FDD_ITP3_available : Boolean;

  HDD_Serial_available : Boolean;


  Serial_Device_connected : Boolean;


  DEVICE_VECTOR_Byte : Byte;


  ConsoleStat, SoundOut : Byte;
  ConsoleIn : Word;
//  ConsoleOut_Attribut, ConsoleOut_Character : Byte;

  ConsoleOut : T_ConsoleOut;


  // STD
  DISKNR : Byte;


  VIDEO_SEND_Routine,
  VIDEO_SEND_Param1,
  VIDEO_SEND_Param2 : Byte;

  VIDEO_GET_Routine,
  VIDEO_GET_Param1,
  VIDEO_GET_Param2 : Byte;

  VIDEO_SysTick_Param : Byte;

  DISK_LBA : Word;

  DEBUG_array : Array [0..20] of Byte;  // ART + 18 = 19 (0..18)

  Date_and_Time_Vector : Array [0..6] of Byte;

  BIOS_Vector : Array [0..9] of Byte;

  DevList_Vector : Array [0..41] of Byte;



  // OFFSET_A
  OFFSET_A : DWord;





  procedure INIT_GlobalDEF;

  procedure Copy_FDD_table_downwards;
  procedure Copy_HDD_table_downwards;
  procedure Copy_FDD_table_upwards;
  procedure Copy_HDD_table_upwards;


implementation




  procedure INIT_Drive_table;
  var
    LV_Zeiger : Word;
  begin

    for LV_Zeiger:=0 to 15 do begin
      FDD_Tabelle[LV_Zeiger]:=no_Device;
    end;

    for LV_Zeiger:=0 to 15 do begin
      Device_List.HDD_table[LV_Zeiger]:=no_Device;
    end;

  end; // INIT_Drive_table







  // *** Laufwerke - Verteiler ***





  procedure Copy_FDD_table_upwards;
  var
    LV_Zeiger : Word;
    LV_Zeiger_M1 : Word;
    es_wurde_kopiert : Boolean;
    Eintrag_Wert : Byte;
    Eintrag_Wert_M1 : Byte;

  begin

    es_wurde_kopiert:=true;

    while es_wurde_kopiert do begin

      es_wurde_kopiert:=false;

      for LV_Zeiger:=15 downto 1 do begin

        Eintrag_Wert:=FDD_Tabelle[LV_Zeiger];

        if Eintrag_Wert=no_Device then begin

          LV_Zeiger_M1:=LV_Zeiger-1;
          Eintrag_Wert_M1:=FDD_Tabelle[LV_Zeiger_M1];

          if Eintrag_Wert_M1<>no_Device then begin

            FDD_Tabelle[LV_Zeiger]:=Eintrag_Wert_M1;
            FDD_Tabelle[LV_Zeiger_M1]:=no_Device;
            es_wurde_kopiert:=true;

          end; // if Eintrag_Wert_M1<>no_Device then

        end; // if Eintrag_Wert=no_Device then

      end; // for LV_Zeiger:=15 downto 1 do

    end; // while es_wurde_kopiert do

  end; // Copy_FDD_table_upwards





  procedure Copy_HDD_table_upwards;
  var
    LV_Zeiger : Word;
    LV_Zeiger_M1 : Word;
    es_wurde_kopiert : Boolean;
    Eintrag_Wert : Byte;
    Eintrag_Wert_M1 : Byte;

  begin

    es_wurde_kopiert:=true;

    while es_wurde_kopiert do begin

      es_wurde_kopiert:=false;

      for LV_Zeiger:=15 downto 1 do begin

        Eintrag_Wert:=Device_List.HDD_table[LV_Zeiger];

        if Eintrag_Wert=no_Device then begin

          LV_Zeiger_M1:=LV_Zeiger-1;
          Eintrag_Wert_M1:=Device_List.HDD_table[LV_Zeiger_M1];

          if Eintrag_Wert_M1<>no_Device then begin

            Device_List.HDD_table[LV_Zeiger]:=Eintrag_Wert_M1;
            Device_List.HDD_table[LV_Zeiger_M1]:=no_Device;
            es_wurde_kopiert:=true;

          end; // if Eintrag_Wert_M1<>no_Device then

        end; // if Eintrag_Wert=no_Device then

      end; // for LV_Zeiger:=15 downto 1 do

    end; // while es_wurde_kopiert do

  end; // Copy_HDD_table_upwards






  procedure Copy_FDD_table_downwards;
  var
    LV_Zeiger : Word;
    LV_Zeiger_P1 : Word;
    es_wurde_kopiert : Boolean;
    Eintrag_Wert : Byte;
    Eintrag_Wert_P1 : Byte;

  begin

    es_wurde_kopiert:=true;

    while es_wurde_kopiert do begin

      es_wurde_kopiert:=false;

      for LV_Zeiger:=0 to 14 do begin

        Eintrag_Wert:=FDD_Tabelle[LV_Zeiger];

        if Eintrag_Wert=no_Device then begin

          LV_Zeiger_P1:=LV_Zeiger+1;
          Eintrag_Wert_P1:=FDD_Tabelle[LV_Zeiger_P1];

          if Eintrag_Wert_P1<>no_Device then begin

            FDD_Tabelle[LV_Zeiger]:=Eintrag_Wert_P1;
            FDD_Tabelle[LV_Zeiger_P1]:=no_Device;
            es_wurde_kopiert:=true;

          end; // if Eintrag_Wert_P1<>no_Device then

        end; // if Eintrag_Wert=no_Device then

      end; // for LV_Zeiger:=0 to 14 do

    end; // while es_wurde_kopiert do

  end; // Copy_FDD_table_downwards







  procedure Copy_HDD_table_downwards;
  var
    LV_Zeiger : Word;
    LV_Zeiger_P1 : Word;
    es_wurde_kopiert : Boolean;
    Eintrag_Wert : Byte;
    Eintrag_Wert_P1 : Byte;

  begin

    es_wurde_kopiert:=true;

    while es_wurde_kopiert do begin

      es_wurde_kopiert:=false;

      for LV_Zeiger:=0 to 14 do begin

        Eintrag_Wert:=Device_List.HDD_table[LV_Zeiger];

        if Eintrag_Wert=no_Device then begin

          LV_Zeiger_P1:=LV_Zeiger+1;
          Eintrag_Wert_P1:=Device_List.HDD_table[LV_Zeiger_P1];

          if Eintrag_Wert_P1<>no_Device then begin

            Device_List.HDD_table[LV_Zeiger]:=Eintrag_Wert_P1;
            Device_List.HDD_table[LV_Zeiger_P1]:=no_Device;
            es_wurde_kopiert:=true;

          end; //  if Eintrag_Wert_P1<>no_Device then

        end; // if Eintrag_Wert=no_Device then

      end; // for LV_Zeiger:=0 to 14 do

    end; // while es_wurde_kopiert do

  end; // Copy_HDD_table_downwards






  procedure INIT_GlobalDEF;
  begin

    DEVICE_VECTOR_Byte:=0;
    INIT_Drive_table;

    Device_List.CONOUT_Device:=no_Device;
    Device_List.CONIN_Device:=no_Device;
    Device_List.LIST_Device:=no_Device;
    Device_List.SOUND_Device:=no_Device;
    Device_List.RTC_Devive:=no_Device;
    Device_List.MOUSE_Device:=no_Device;

    ConsoleIn:=0;
    ConsoleStat:=0;
    ConsoleOut.Attribute:=$07;
    ConsoleOut.Character:=$20;

    RMouse.Button:=0;
    RMouse.X:=0;
    RMouse.Y:=0;

    DISKNR:=0;

    // Voreinstellung ohne BIOS-FLASH
    // wird dann vom BIOS-Eintrag ueberschrieben
    // BIOS_REC.BOOT_DRIVE:=BOOT_DRIVE_Serial;
    BIOS_REC.BOOT_DRIVE:=BOOT_DRIVE_lokal_Flash;

    Device_List.FDD_LW_A:=no_Device;
    Device_List.FDD_LW_B:=no_Device;

    FDD_Serial_available:=false;
//    FDD_lokal_Flash_available:=false;
    FDD_ITP3_available:=false;

    HDD_Serial_available:=false;


    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    Device_List.MOUSE_Device:=Device_Serial;



  end; // INIT_GlobalDEF




end. // GlobalVAR_U


