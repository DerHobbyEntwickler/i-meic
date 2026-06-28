unit BIOSAdmin_U;
{$MODE OBJFPC}


interface


uses
  pico_c,
  pico_flash_c,

  GlobalDEF_U,
  GlobalHW_U,
  UART_U;




const
  CONST_BIOS_CODE : Word = $A219;


  procedure INIT_BIOS_FLASH;

  procedure WRITE_BIOS_Vektor_to_BIOS;
  procedure READ_BIOS_Vektor_from_BIOS;


implementation

{ FLASH-Definitionen - Anfang }
const

  FLASH_SECTOR_SIZE = 4096;
  FLASH_PAGE_SIZE   = 256;

  // letzter Flashsektor bei 1MB Flash
  FLASH_TARGET_OFFSET = $100000 - FLASH_SECTOR_SIZE;


type
  TFlashPage = array[0..FLASH_PAGE_SIZE-1] of Byte;

const
  FLASH_ADDRESS = XIP_BASE + FLASH_TARGET_OFFSET;

var

  // direkter Zugriff auf Flashbereich
  FlashPage : TFlashPage absolute FLASH_ADDRESS;

  // BIOS_REC : T_BIOS_REC;



  procedure LoadSettings;
  begin
    Move(FlashPage[0], BIOS_REC, SizeOf(BIOS_REC));
  end; // LoadSettings



  procedure SaveSettings;
  var
    Buffer : TFlashPage;
  begin
    FillChar(Buffer, SizeOf(Buffer), $FF);

    Move(BIOS_REC, Buffer[0], SizeOf(BIOS_REC));

    // Flashsektor löschen
    flash_range_erase(
      FLASH_TARGET_OFFSET,
      FLASH_SECTOR_SIZE
    );

    // Flash programmieren
    flash_range_program(
      FLASH_TARGET_OFFSET,
      Buffer,
      FLASH_PAGE_SIZE
    );
  end;





  { FLASH-Definitionen - Ende }




  procedure BIOS_Read_DATA_DEFAULT;
  begin

    BIOS_REC.BIOS_CODE:=CONST_BIOS_CODE;
    BIOS_REC.BOOT_DRIVE:=BOOT_DRIVE_Serial;

  end; // BIOS_Read_DATA_DEFAULT




  procedure BIOS_Write_DATA_to_FLASH;
  begin
    SaveSettings;
  end; // BIOS_Write_DATA_to_FLASH




  procedure BIOS_Read_DATA_from_FLASH;
  begin

    LoadSettings;

    if BIOS_REC.BIOS_CODE=CONST_BIOS_CODE  then begin

      BIOS_REC.BOOT_DRIVE:=BIOS_REC.BOOT_DRIVE;

    end // if Sektor_Puffer[0]=CONST_BIOS_CODE1 then
    else begin

      BIOS_Read_DATA_DEFAULT;
      BIOS_Write_DATA_to_FLASH;

    end;

  end; // BIOS_Read_DATA_from_FLASH





  procedure INIT_BIOS_FLASH;
  begin

    BIOS_Read_DATA_from_FLASH;

    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 //   BIOS_REC.BOOT_DRIVE:=BOOT_DRIVE_lokal_Flash;
//    BIOS_REC.BOOT_DRIVE:=BOOT_DRIVE_ITP3;
//    BIOS_REC.BOOT_DRIVE:=BOOT_DRIVE_Serial;


    case BIOS_REC.BOOT_DRIVE of
      BOOT_DRIVE_no          : BIOS_REC.BOOT_DRIVE:=BOOT_DRIVE_Serial;
      BOOT_DRIVE_Serial      : UART_WriteLn_Text('yBOOT_DRIVE=Serial');
      BOOT_DRIVE_lokal_Flash : UART_WriteLn_Text('yBOOT_DRIVE=lokal Flash');
      BOOT_DRIVE_ITP3        : UART_WriteLn_Text('yBOOT_DRIVE=ITP3');
    else

      BIOS_REC.BOOT_DRIVE:=BOOT_DRIVE_Serial;

    end;


    //
    case BIOS_REC.BOOT_DRIVE of


      BOOT_DRIVE_Serial      : begin
                                 if FDD_Serial_available then begin
                                   Device_List.FDD_LW_A:=Device_Serial;

                                   if FDD_ITP3_available then
                                     Device_List.FDD_LW_B:=FDD_Tabelle[0];

                                 end // if FDD_Serial_vorhanden then
                                 else begin

                                   if FDD_ITP3_available then begin
                                     Device_List.FDD_LW_A:=FDD_Tabelle[0];

                                     if FDD_Tabelle[1]<>no_Device then
                                       Device_List.FDD_LW_B:=FDD_Tabelle[1];

                                   end; // if FDD_ITP3_vorhanden then

                                 end; // else FDD_Serial_vorhanden then
                               end; // BOOT_DRIVE_Serial



      BOOT_DRIVE_ITP3        : begin
                                 if FDD_ITP3_available then begin
                                   Device_List.FDD_LW_A:=FDD_Tabelle[0];

                                   Device_List.FDD_LW_B:=Device_Serial;

                                   if FDD_Tabelle[1]<>no_Device then
                                     Device_List.FDD_LW_B:=FDD_Tabelle[1];

                                 end // if FDD_ITP3_vorhanden then
                                 else begin

                                   if FDD_Serial_available then
                                     Device_List.FDD_LW_A:=Device_Serial;

                                 end; // else if FDD_ITP3_vorhanden then
                               end; // BOOT_DRIVE_ITP3


    end; // case BIOS_REC.BOOT_DRIVE of

  end; // INIT_BIOS_FLASH





  procedure READ_BIOS_Vektor_from_BIOS;
  begin

    BIOS_Read_DATA_from_FLASH;

    BIOS_Vector[0]:=BIOS_REC.BOOT_DRIVE;

    BIOS_Vector[1]:=0;
    BIOS_Vector[2]:=0;
    BIOS_Vector[3]:=0;
    BIOS_Vector[4]:=0;
    BIOS_Vector[5]:=0;
    BIOS_Vector[6]:=0;
    BIOS_Vector[7]:=0;
    BIOS_Vector[8]:=0;
    BIOS_Vector[9]:=0;

  end; // READ_BIOS_Vektor_from_BIOS





  procedure WRITE_BIOS_Vektor_to_BIOS;
  begin

    BIOS_Read_DATA_from_FLASH;
    BIOS_REC.BOOT_DRIVE:=BIOS_Vector[0];
    BIOS_Write_DATA_to_FLASH;

  end; // WRITE_BIOS_Vektor_to_BIOS





end.

