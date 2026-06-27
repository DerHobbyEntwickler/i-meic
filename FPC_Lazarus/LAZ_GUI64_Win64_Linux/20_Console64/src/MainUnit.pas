unit MainUnit;

{$mode objfpc}{$H+}{$M+}

interface

uses
  Classes, SysUtils, FileUtil, LazSerial, LResources, Forms, Controls,
  Graphics, Dialogs, StrUtils, synaser,

  {$IFDEF MSWINDOWS}
    Windows, Registry,
  {$ENDIF}

  {$IFDEF UNIX}{$IFNDEF DARWIN}
    Process,   // RunCommand fuer "udevadm info" unter Linux
  {$ENDIF}{$ENDIF}

  StdCtrls, ExtCtrls, Buttons, ComCtrls, IniFiles, DateUtils, Types,
  Unit_CONS, windos, Language_U;




// Abfrage von CONST und CONIN vom Controller
{$DEFINE CONST_Abfrage}


const

  CRLF = CHR($0D)+CHR($0A);
//  CR = CHR($0D);
  XOFF = CHR($13);
  Length_ConsoleIn = 20;

  Length_Color_List = 100000;

  // Farben
  cl_dark_green = $009500;
  cl_dark_blue  = $650106;
  cl_dark_red   = $0000CA;
  cl_dark_brown = $000066;

  cl_green_INT10  = $4F4F2F; // DarkSlateGray 2F4F4F
  cl_green_INT13  = $B48246; // SteelBlue 4682B4
  cl_green_INT16  = $008080; // Olive     808000
  cl_green_INT1A  = $6BB7BD; // DarkKhaki BDB76B

  COM_Port_Max = 99;


  // fuer
  LEN_CMD_WRITE_LBA_SECTOR = 7;




  {$IFDEF MSWINDOWS}
     path_separator = '\';
  {$ELSE}
     path_separator = '/';
  {$ENDIF}





type


  REC_Port_List = record
    Port_Name, Port_Typ : String;
  end;



  { TForm_Console }

  TForm_Console = class(TForm)
    BitBtn_Drive_Save: TBitBtn;
    BitBtn_HDD_00: TBitBtn;
    BitBtn_FDD_00: TBitBtn;
    BitBtn_Save_Screen: TBitBtn;
    BitBtn_Print_Save: TBitBtn;
    Button_LOG_Messages_Save: TButton;
    Button_LOG_Messages_Clear: TButton;
    Button_Font_apply: TButton;
    Button_Close: TButton;
    CheckBox_lang_de: TCheckBox;
    CheckBox_lang_en: TCheckBox;
    CheckBox_LOG_MOUSE: TCheckBox;
    CheckBox_GV2_D7_Mouse: TCheckBox;
    CheckBox_GV_D1_RTC: TCheckBox;
    CheckBox_LOG_DEBUG: TCheckBox;
    CheckBox_GV_D2_HDD: TCheckBox;
    CheckBox_GV_FDD: TCheckBox;
    CheckBox_GV_D4_SOUND: TCheckBox;
    CheckBox_GV_D5_LIST: TCheckBox;
    CheckBox_GV_D6_CONIN: TCheckBox;
    CheckBox_GV_D7_VIDEO: TCheckBox;
    CheckBox_XOFF: TCheckBox;
    CheckBox_LOG_TERM: TCheckBox;
    CheckBox_LOG_WRITE: TCheckBox;
    CheckBox_LOG_READ: TCheckBox;
    CheckBox_LOG_CONOUT: TCheckBox;
    CheckBox_LOG_CONIN: TCheckBox;
    ComboBox_Font_Namen: TComboBox;
    ComboBox_FontSize: TComboBox;
    ComboBoxBauds: TComboBox;
    ComboBoxPort: TComboBox;
    Edit_HDD_00_Description: TEdit;
    Edit_FDD_00_Description: TEdit;
    ImageList1: TImageList;
    Image_DISK_MONITOR: TImage;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label_HDD: TLabel;
    Label_FDD: TLabel;
    Label_LBA: TLabel;
    Label_DISK: TLabel;
    LazSerial1: TLazSerial;
    LED_GE: TImage;
    LED_GN: TImage;
    LED_RT: TImage;
    Image_rt: TImage;
    Image_gn: TImage;
    Label1: TLabel;
    Label2: TLabel;
    PageControl1: TPageControl;
    Panel3: TPanel;
    Panel_HDD: TPanel;
    Panel_FDD: TPanel;
    Panel_DISK: TPanel;
    Panel6: TPanel;

    TabSheet_Language: TTabSheet;
    TabSheet_Debug: TTabSheet;
    TabSheet_Drive: TTabSheet;
    TabSheet_Settings: TTabSheet;
    TabSheet_Monitor: TTabSheet;


    ListBox_Messages: TListBox;
    OpenDialog_IMAGE: TOpenDialog;
    OpenDialog_BOOT: TOpenDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    ConnectButton: TButton;
    Timer1: TTimer;
    Timer2: TTimer;

    procedure BitBtn_Drive_SaveClick(Sender: TObject);
    procedure BitBtn_Print_SaveClick(Sender: TObject);
    procedure BitBtn_Save_ScreenClick(Sender: TObject);
    procedure BitBtn_Terminal_SaveClick(Sender: TObject);
    procedure Button_Font_applyClick(Sender: TObject);
    procedure Button_CloseClick(Sender: TObject);
    procedure Button_LOG_Messages_ClearClick(Sender: TObject);
    procedure Button_LOG_Messages_SaveClick(Sender: TObject);
    procedure Button_Save_DrivesClick(Sender: TObject);
    procedure CheckBox_GV_D2_HDDChange(Sender: TObject);
    procedure CheckBox_GV_FDDChange(Sender: TObject);
    procedure CheckBox_GV_D4_SOUNDChange(Sender: TObject);
    procedure CheckBox_GV_D5_LISTChange(Sender: TObject);
    procedure CheckBox_GV_D6_CONINChange(Sender: TObject);
    procedure CheckBox_GV_D7_VIDEOChange(Sender: TObject);
    procedure CheckBox_GV_D1_RTCChange(Sender: TObject);
    procedure CheckBox_lang_deChange(Sender: TObject);
    procedure CheckBox_lang_enChange(Sender: TObject);
    procedure CheckBox_LOG_CONINChange(Sender: TObject);
    procedure CheckBox_LOG_CONOUTChange(Sender: TObject);
    procedure CheckBox_LOG_READChange(Sender: TObject);
    procedure CheckBox_LOG_WRITEChange(Sender: TObject);
    procedure ComboBox_FontSizeChange(Sender: TObject);
    procedure ConnectButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LazSerial1RxData(Sender: TObject);
    procedure ListBox_MessagesDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure RadioGroup1Click(Sender: TObject);
    procedure TerminalKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
      );
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
  private
    { private declarations }
    PortConnected : Boolean;
    FIni : TMemIniFile;
    PRINT_File_Name : String;
    ReadCOM : String;
    VAR_DISKNO, VAR_LBA,
    F1_x, F1_y, F1_Height : Integer;
    PRINT_File : TMemoryStream;
    Pos_ConsoleIn : Byte;
    Trace_List : TStringList;
    Com_Port : string;
    DISK_MONITOR_Counter : Integer;
    last_Checksum : Integer;
    DEVICE_VECTOR_String : String;
    Color_List : Array [0..Length_Color_List] of TColor;
    INT_Color : TColor;

    COM_Port_Array : Array [0..COM_Port_Max] of REC_Port_List;
    COM_Port_Array_Index : Integer;

    Video_RAM_File : TStringList;

    Error_Pass : Integer;

    INI_Baud_Rate: integer;


    procedure Port_Connect;
    procedure DISK_MONITOR_OFF;
    procedure DISK_MONITOR_READ;
    procedure DISK_MONITOR_WRITE;
    procedure WRITE_TO_LIST(DatenByte : Byte);
    procedure send_Date_and_Time;
    procedure send_CONIN;
    procedure send_CONST;
    procedure send_MOUSE(SM_Param : Char);
    procedure send_DEVICE_VECTOR;
    procedure ComPort_Load;
    procedure LBA_Sector_read_from_UART;
    procedure LBA_Sector_write_to_UART(WR_Line : String);
    procedure Delay(Milliseconds: Integer);
    procedure DEBUG_Register(DEBUG_Line : String);
    procedure send_VIDEO_GET_Parameter(DB_Routine : Byte);
    procedure Write_VIDEO_Column_Section(Row : String);
    function txtf(txt_nr : Word) : String;
    function txtp(txt_nr : Word) : String;
    procedure load_INI_File;

  public
    { public declarations }
    Program_File_Path, PRINT_File_Folder : string;
    F2_x, F2_y : Integer;
    LOG_CONIN, LOG_CONOUT,
    LOG_READ, LOG_WRITE, LOG_DEBUG,
    LOG_DEVICE_VECTOR : Boolean;
    DEVICE_VECTOR_Byte : Byte;

    procedure ComboBox_FontSize_query;
    procedure ComboBox_FontSize_change;
    function find_Font_Name : Integer;
    procedure ListBox_Messages_Clear;
    procedure ListBox_Messages_Add_Item_Color(AI_Text : String;
                                              AI_Color : TColor);

  end; { TForm_Console }

var
  Form_Console: TForm_Console;
  Language_Init : Boolean;

  // globale Variablen
  GV_Font_Name : String;
  CONS_FontSize : Integer;
  set_Focus_on_CONOUT : Boolean;


  const ligneMax = 30;

implementation

{ TForm_Console }





procedure change_language_in_Form_Console;
begin
  with Form_Console do
  begin
    // oberer Abschnitt im Formular
    ConnectButton.Caption:=txtf(001);
    Label1.Caption:=txtf(002);
    Label2.Caption:=txtf(003);


    // 2. Abschnitt (Geraeteverwaltung)
    Label4.Caption:=txtf(008);
    CheckBox_GV_D7_VIDEO.Caption:=txtf(007);
    CheckBox_GV_D6_CONIN.Caption:=txtf(009);
    CheckBox_GV_D5_LIST.Caption:=txtf(010);
    CheckBox_GV_D4_SOUND.Caption:=txtf(011);
    CheckBox_GV_FDD.Caption:=txtf(012);
    CheckBox_GV_D2_HDD.Caption:=txtf(013);
    CheckBox_GV_D1_RTC.Caption:=txtf(014);
    CheckBox_GV2_D7_Mouse.Caption:=txtf(015);


    // Reiter Monitor
    BitBtn_Drive_Save.Caption:=txtf(017);
    BitBtn_Print_Save.Caption:=txtf(026);

    // Reiter Laufwerke (Image: = unwichtig)
    Label_FDD.Caption:=txtf(035);
    Label_HDD.Caption:=txtf(035);

    // Reiter Einstellungen
    CheckBox_XOFF.Caption:=txtf(027);
    Label6.Caption:=txtf(023);
    Button_Font_apply.Caption:=txtf(024);
    Label3.Caption:=txtf(020);
    BitBtn_Save_Screen.Caption:=txtf(022);
    CheckBox_LOG_TERM.Caption:=txtf(021);

    // Reiter Sprache
    Label5.Caption:=txtf(038);
    CheckBox_lang_de.Caption:=txtf(037);
    CheckBox_lang_en.Caption:=txtf(038);

    // Reiter Debug
    CheckBox_LOG_CONIN.Caption:=txtf(028);
    CheckBox_LOG_CONOUT.Caption:=txtf(029);
    CheckBox_LOG_READ.Caption:=txtf(030);
    CheckBox_LOG_WRITE.Caption:=txtf(031);
    CheckBox_LOG_DEBUG.Caption:=txtf(032);
    CheckBox_LOG_MOUSE.Caption:=txtf(033);


    // Bezeichnungen der Reiter
    TabSheet_Monitor.Caption:=txtf(016);
    TabSheet_Drive.Caption:=txtf(034);
    TabSheet_Settings.Caption:=txtf(025);
    TabSheet_Language.Caption:=txtf(036);
    TabSheet_Debug.Caption:=txtf(018);


    // letzter Abschnitt im Formular unten
    Button_LOG_Messages_Clear.Caption:=txtf(005);
    Button_LOG_Messages_Save.Caption:=txtf(006);
    Button_Close.Caption:=txtf(004);

  end;
end; { change_language_in_Form_Console }


procedure TForm_Console.FormCreate(Sender: TObject);
var

  DV_counter : Integer;
  DEVICE_VECTOR_String2 : String;


  function date_as_string : String;
  var
    meinDatum: TDate;
    datumAlsString: string;
  begin
    meinDatum := Date; // Aktuelles Datum holen

    // Methode 1: Standardkonvertierung
    datumAlsString := DateToStr(meinDatum);

    Result:=datumAlsString;
  end;




begin

  INT_Color:=cl_dark_green;

  ComboBoxPort.Clear;

  LOG_DEVICE_VECTOR:=TRUE;

  Form_Console.Caption:='DOS CONSOLE64 - Version '+
                         date_as_string+' (c) by Ronald Daleske';

  INI_Baud_Rate:=0;
  load_INI_File;


  // Geraeteverwaltung und DEVICE_VECTOR
  if Length(DEVICE_VECTOR_String)=8 then begin

    DEVICE_VECTOR_String2:='';

    for DV_counter:=1 to 8 do begin

      if DEVICE_VECTOR_String[DV_counter]='0' then
        DEVICE_VECTOR_String2:=DEVICE_VECTOR_String2+'0'
      else
        DEVICE_VECTOR_String2:=DEVICE_VECTOR_String2+'1'

    end;

    DEVICE_VECTOR_Byte := StrToIntDef( '%' + DEVICE_VECTOR_String2,0);

  end
  else begin
    DEVICE_VECTOR_String:='00000000';
    DEVICE_VECTOR_Byte := 0;
  end;




  {
    Konfiguration WHO_ARE_YOU - Byte
    D7 - CONOUT
    D6 - CONIN
    D5 - LIST
    D4 - SOUND
    D3 - FDD
    D2 - HDD
    D1 - N.N.
    D0 - N.N.
  }

  // Setzen der Check-Boxen fuer die Geraeteverwaltung
  if (DEVICE_VECTOR_Byte and %10000000=0) then
    CheckBox_GV_D7_VIDEO.Checked:=false
  else
    CheckBox_GV_D7_VIDEO.Checked:=true;


  if (DEVICE_VECTOR_Byte and %01000000=0) then
    CheckBox_GV_D6_CONIN.Checked:=false
  else
    CheckBox_GV_D6_CONIN.Checked:=true;


  if (DEVICE_VECTOR_Byte and %00100000=0) then
    CheckBox_GV_D5_LIST.Checked:=false
  else
    CheckBox_GV_D5_LIST.Checked:=true;


  if (DEVICE_VECTOR_Byte and %00010000=0) then
    CheckBox_GV_D4_SOUND.Checked:=false
  else
    CheckBox_GV_D4_SOUND.Checked:=true;


  if (DEVICE_VECTOR_Byte and %00001000=0) then
    CheckBox_GV_FDD.Checked:=false
  else
    CheckBox_GV_FDD.Checked:=true;


  if (DEVICE_VECTOR_Byte and %00000100=0) then
    CheckBox_GV_D2_HDD.Checked:=false
  else
    CheckBox_GV_D2_HDD.Checked:=true;


  if (DEVICE_VECTOR_Byte and %00000010=0) then
    CheckBox_GV_D1_RTC.Checked:=false
  else
    CheckBox_GV_D1_RTC.Checked:=true;



  ReadCOM:='';
  ListBox_Messages.Clear;


  ComPort_Load;



  ComboBoxBauds.Items.Add('  9600');
  ComboBoxBauds.Items.Add(' 19200');
  ComboBoxBauds.Items.Add(' 38400');
  ComboBoxBauds.Items.Add(' 57600');
  ComboBoxBauds.Items.Add(' 62500');
  ComboBoxBauds.Items.Add('115200');
  ComboBoxBauds.Items.Add('100000');
  ComboBoxBauds.Items.Add('125000');
  ComboBoxBauds.Items.Add('128000');
  ComboBoxBauds.Items.Add('200000');
  ComboBoxBauds.Items.Add('230400');
  ComboBoxBauds.Items.Add('250000');
  ComboBoxBauds.Items.Add('460800');
  ComboBoxBauds.Items.Add('500000');
  ComboBoxBauds.Items.Add('921600');

  ComboBoxBauds.ItemIndex:=INI_Baud_Rate;



  ConnectButton.Caption:=txtp(003);
  PortConnected:=false;

  Image_rt.Visible:=true;
  Image_gn.Visible:=false;





  // PRINT
  PRINT_File := TMemoryStream.Create;

  DISK_MONITOR_OFF;
  Pos_ConsoleIn := 0;

  Trace_List := TStringList.Create;

  DISK_MONITOR_Counter:=0;
  Timer1.Enabled:=true;

  last_Checksum:=0;



  ComboBox_FontSize.Items.Add('FontSize=6');
  ComboBox_FontSize.Items.Add('FontSize=8');
  ComboBox_FontSize.Items.Add('FontSize=10');
  ComboBox_FontSize.Items.Add('FontSize=14');
  ComboBox_FontSize.Items.Add('FontSize=16');
  ComboBox_FontSize.Items.Add('FontSize=18');
  ComboBox_FontSize.Items.Add('FontSize=20');
  ComboBox_FontSize.Items.Add('FontSize=22');
  ComboBox_FontSize.Items.Add('FontSize=24');
  ComboBox_FontSize.Items.Add('FontSize=26');


  ComboBox_FontSize.ItemIndex := FIni.ReadInteger('CONOUT', 'Index_FontSize', 2);

  ComboBox_Font_Namen.Items.Assign(Screen.Fonts);

  ComboBox_Font_Namen.ItemIndex:=find_Font_Name;


  ListBox_Messages_Clear;

  Video_RAM_File:=TStringList.Create;


  // Laden des DOS-Laufwerkes
  wdos_Drive := Twdos.Create;

  Form_Console.KeyPreview:=true;

  Error_Pass:=0;



  change_language_in_Form_Console;

end; { procedure TForm_Console.FormCreate }






procedure TForm_Console.load_INI_File;
var
  lang_index : Integer;
begin

  Program_File_Path := ExtractFilePath(Application.ExeName);
  FIni := TMemIniFile.Create(Program_File_Path +'CONSOLE64.ini');

  // IniFile ComPort
  Com_Port := FIni.ReadString('ComPort', 'ComPort', 'COM1');
  INI_Baud_Rate := FIni.ReadInteger('ComPort', 'BaudRate', 0);

  // IniFile PRINT
  PRINT_File_Name := FIni.ReadString('PRINT', 'File_Name', 'PRINT.txt');
  PRINT_File_Folder := FIni.ReadString('PRINT', 'File_Ordner', 'PRINT');

  // IniFile FORM
  F1_x := FIni.ReadInteger('FORM', 'F1_x', 0);
  F1_y := FIni.ReadInteger('FORM', 'F1_y', 0);
  F1_Height := FIni.ReadInteger('FORM', 'F1_Height', 670);
  F2_x := FIni.ReadInteger('FORM', 'F2_x', 0);
  F2_y := FIni.ReadInteger('FORM', 'F2_y', 0);

  LOG_CONIN := FIni.ReadBool('FORM', 'LOG_CONIN', true);
  CheckBox_LOG_CONIN.Checked := LOG_CONIN;
  LOG_CONOUT := FIni.ReadBool('FORM', 'LOG_CONOUT', true);
  CheckBox_LOG_CONOUT.Checked := LOG_CONOUT;
  LOG_READ := FIni.ReadBool('FORM', 'LOG_READ', true);
  CheckBox_LOG_READ.Checked := LOG_READ;
  LOG_WRITE := FIni.ReadBool('FORM', 'LOG_WRITE', true);
  CheckBox_LOG_WRITE.Checked := LOG_WRITE;
  LOG_DEBUG := FIni.ReadBool('FORM', 'LOG_DEBUG', true);
  CheckBox_LOG_DEBUG.Checked := LOG_DEBUG;

  CheckBox_LOG_TERM.Checked := FIni.ReadBool('FORM', 'LOG_Term', false);
  CheckBox_XOFF.Checked := FIni.ReadBool('FORM', 'send_XOFF', true);


  // IniFile ListBox_Messages

  DEVICE_VECTOR_String := FIni.ReadString('CONOUT', 'DEVICE_VECTOR', '11111100');
  GV_Font_Name := FIni.ReadString('CONOUT', 'FONT_NAME', 'Courier New');


  // Language, Sprache

  Language_Init:=true;

  lang_index := FIni.ReadInteger('CONSOLE64', 'LANGUAGE', 0);

  case lang_index of
    0 : begin
          lang_var:=lang_de;
          CheckBox_lang_de.Checked:=true;
          CheckBox_lang_en.Checked:=false;
        end;
    1 : begin
          CheckBox_lang_en.Checked:=true;
          CheckBox_lang_de.Checked:=false;
          lang_var:=lang_en;
        end
  else
    begin
      lang_var:=lang_de;
      CheckBox_lang_de.Checked:=true;
      CheckBox_lang_en.Checked:=false;
    end
  end;

  Language_Init:=false;






end; { procedure TForm_Console.load_INI_File }






function TForm_Console.find_Font_Name : Integer;
var
  FN_ItemIndex,
  FN_Counter : Integer;
begin

  FN_ItemIndex:=-1;

  for FN_Counter:=0 to ComboBox_Font_Namen.Items.Count-1 do begin

    if ComboBox_Font_Namen.Items[FN_Counter]=GV_Font_Name then begin
      FN_ItemIndex:=FN_Counter;
    end; { if ComboBox_Font_Namen.Items[FN_Counter]=GV_Font_Name then }

  end; { for FN_Counter:=0 to ComboBox_Font_Namen.Items.Count-1 do }



  if FN_ItemIndex=-1 then begin

    FN_ItemIndex:=0;

    for FN_Counter:=0 to ComboBox_Font_Namen.Items.Count-1 do begin

      if ComboBox_Font_Namen.Items[FN_Counter]='Lucida Console' then begin
        FN_ItemIndex:=FN_Counter;
      end; { if ComboBox_Font_Namen.Items[FN_Counter]=GV_Font_Name then }

    end; { for FN_Counter:=0 to ComboBox_Font_Namen.Items.Count-1 do }

  end; { if FN_ItemIndex=-1 then }


  Result:=FN_ItemIndex;

end; { function TForm_Console.find_Font_Name }











// ****************
// *** COM-Port ***
// ****************







{ ------------------------------------------------------------------------------
  GetComFriendlyName

  Liefert zu einem Portnamen (z.B. "COM3" unter Windows oder "/dev/ttyUSB0"
  unter Linux) den Klartextnamen des Geraetes, z.B.
  "Silicon Labs CP210x USB to UART Bridge".

  Wird kein Klartextname gefunden, ist das Ergebnis ein leerer String.

  Es wird KEINE zusaetzliche Komponente verwendet:
    - Windows: Auswertung der Registry (CurrentControlSet\Enum)
    - Linux:   Auswertung von "udevadm info"
    - macOS:   (kein Klartextname)
------------------------------------------------------------------------------ }

{$IFDEF MSWINDOWS}
{ Durchsucht rekursiv den Enum-Zweig der Registry nach dem Geraeteknoten,
  dessen "Device Parameters\PortName" mit dem gesuchten Port uebereinstimmt,
  und liefert dessen "FriendlyName". }
function FindFriendlyNameInEnum(Reg: TRegistry; const BaseKey, PortName: string): string;
var
  SubKeys: TStringList;
  i: Integer;
  PortVal: string;
begin
  Result := '';
  SubKeys := TStringList.Create;
  try
    try
      if not Reg.OpenKeyReadOnly(BaseKey) then
        Exit;
      Reg.GetKeyNames(SubKeys);
      Reg.CloseKey;

      { Traegt dieser Knoten direkt unseren Port? }
      if Reg.OpenKeyReadOnly(BaseKey + '\Device Parameters') then
      begin
        if Reg.ValueExists('PortName') then
          PortVal := Reg.ReadString('PortName')
        else
          PortVal := '';
        Reg.CloseKey;

        if SameText(PortVal, PortName) then
        begin
          if Reg.OpenKeyReadOnly(BaseKey) then
          begin
            if Reg.ValueExists('FriendlyName') then
              Result := Reg.ReadString('FriendlyName');
            Reg.CloseKey;
          end;
          Exit;
        end;
      end;

      { andernfalls in die Unterschluessel absteigen }
      for i := 0 to SubKeys.Count - 1 do
      begin
        if SameText(SubKeys[i], 'Device Parameters') then
          Continue;
        Result := FindFriendlyNameInEnum(Reg, BaseKey + '\' + SubKeys[i], PortName);
        if Result <> '' then
          Exit;
      end;
    except
      { Ein einzelner, nicht lesbarer Zweig darf die Suche nicht abbrechen }
      Result := '';
    end;
  finally
    SubKeys.Free;
  end;
end;

function GetComFriendlyName(const PortName: string): string;
var
  Reg: TRegistry;
  p: Integer;
begin
  Result := '';
  Reg := TRegistry.Create;
  try
    try
      Reg.RootKey := HKEY_LOCAL_MACHINE;
      Result := FindFriendlyNameInEnum(Reg, '\SYSTEM\CurrentControlSet\Enum', PortName);
    except
      Result := '';
    end;
  finally
    Reg.Free;
  end;

  { Windows haengt an den FriendlyName meist " (COMx)" an -> fuer die Anzeige entfernen }
  p := Pos(' (' + PortName + ')', Result);
  if p > 0 then
    Delete(Result, p, Length(Result));
  Result := Trim(Result);
end;
{$ELSE}
  {$IFDEF DARWIN}
  function GetComFriendlyName(const PortName: string): string;
  begin
    Result := '';
  end;
  {$ELSE}
  { Linux: Klartextnamen ueber "udevadm info" ermitteln }
  function GetComFriendlyName(const PortName: string): string;
  var
    Output: string;
    model, vendor: string;

    function Extract(const Key: string): string;
    var
      sp, ep: Integer;
    begin
      Result := '';
      sp := Pos(Key, Output);
      if sp = 0 then
        Exit;
      Inc(sp, Length(Key));
      ep := Pos(#10, Output, sp);
      if ep = 0 then
        ep := Length(Output) + 1;
      Result := Trim(Copy(Output, sp, ep - sp));
    end;

  begin
    Result := '';
    Output := '';
    try
      if not RunCommand('udevadm', ['info', '-q', 'property', PortName], Output) then
        if not RunCommand('udevadm', ['info', '--query=property', '--name=' + PortName], Output) then
          Exit;
    except
      Exit;
    end;

    model := Extract('ID_MODEL_FROM_DATABASE=');
    if model = '' then
      model := Extract('ID_MODEL=');
    vendor := Extract('ID_VENDOR_FROM_DATABASE=');
    if vendor = '' then
      vendor := Extract('ID_VENDOR=');

    if (model <> '') and (vendor <> '') and
       (Pos(LowerCase(vendor), LowerCase(model)) = 0) then
      Result := vendor + ' ' + model
    else if model <> '' then
      Result := model
    else
      Result := vendor;

    Result := Trim(StringReplace(Result, '_', ' ', [rfReplaceAll]));
  end;
  {$ENDIF}
{$ENDIF}





procedure TForm_Console.ComPort_Load;
var
  Port_List : string;
  Com, Description_Text : string;
  p : Integer;
begin

  { Verfuegbare serielle Schnittstellen plattformuebergreifend ueber synaser
    ermitteln. GetSerialPortNames liefert eine kommagetrennte Liste, z.B.
    unter Windows "COM1,COM3" bzw. unter Linux
    "/dev/ttyS0,/dev/ttyUSB0,/dev/ttyACM0".
    Zu jedem Port wird der Klartextname ergaenzt, z.B.
    "COM3 = Silicon Labs CP210x USB to UART Bridge".
    Der reine Portname steht parallel in COM_Port_Array[].Port_Name und wird
    von Port_Connect zum Oeffnen der Schnittstelle benutzt. }

  COM_Port_Array_Index := 0;

  ComboBoxPort.Items.Clear;
  ComboBoxPort.ItemIndex := -1;

  Port_List := GetSerialPortNames;

  if Port_List > '' then
    repeat
      p := Pos(',', Port_List);
      if p > 0 then begin
        Com := Trim(Copy(Port_List, 1, p - 1));
        Delete(Port_List, 1, p);
      end
      else begin
        Com := Trim(Port_List);
        Port_List := '';
      end;

      if (Com <> '') and (COM_Port_Array_Index <= COM_Port_Max) then begin

        Description_Text := GetComFriendlyName(Com);

        COM_Port_Array[COM_Port_Array_Index].Port_Name := Com;
        COM_Port_Array[COM_Port_Array_Index].Port_Typ  := Description_Text;

        if Description_Text <> '' then
          ComboBoxPort.Items.Add(Com + ' = ' + Description_Text)
        else
          ComboBoxPort.Items.Add(Com);

        { gespeicherten Port (reiner Name) wiederfinden }
        if Com_Port = Com then
          ComboBoxPort.ItemIndex := COM_Port_Array_Index;

        Inc(COM_Port_Array_Index);

      end;
    until Port_List = '';

  if (ComboBoxPort.ItemIndex = -1) and (ComboBoxPort.Items.Count > 0) then
    ComboBoxPort.ItemIndex := ComboBoxPort.Items.Count - 1;

end; { procedure TForm_Console.ComPort_Load }






procedure TForm_Console.Port_Connect;
var
  bauds: Integer;
  PortName, BaudRate : String;
begin

  if not LazSerial1.Active then begin

    BaudRate:=ComboBoxBauds.Items[ComboBoxBauds.itemindex];

    case ComboBoxBauds.itemindex of

      00 : LazSerial1.BaudRate:=br__9600;
      01 : LazSerial1.BaudRate:=br_19200;
      02 : LazSerial1.BaudRate:=br_38400;
      03 : LazSerial1.BaudRate:=br_57600;
      04 : LazSerial1.BaudRate:=br_62500;
      05 : LazSerial1.BaudRate:=br100000;
      06 : LazSerial1.BaudRate:=br115200;
      07 : LazSerial1.BaudRate:=br125000;
      08 : LazSerial1.BaudRate:=br128000;
      09 : LazSerial1.BaudRate:=br200000;
      10 : LazSerial1.BaudRate:=br230400;
      11 : LazSerial1.BaudRate:=br250000;
      12 : LazSerial1.BaudRate:=br460800;
      13 : LazSerial1.BaudRate:=br500000;
      14 : LazSerial1.BaudRate:=br921600;

    end; { case ComboBoxBauds.itemindex of }


    if (ComboBoxPort.ItemIndex < 0) or
       (ComboBoxPort.ItemIndex >= COM_Port_Array_Index) then begin
      ListBox_Messages_Add_Item_Color(txtp(001),cl_dark_red);
      Exit;
    end;

    PortName:=COM_Port_Array[ComboBoxPort.ItemIndex].Port_Name;
    LazSerial1.Device:=PortName;

    LazSerial1.Open;

    ConnectButton.Caption:=txtp(002);
    PortConnected:=true;
    Image_rt.Visible:=false;
    Image_gn.Visible:=true;
    ListBox_Messages_Add_Item_Color('--- Port '+
                                    LazSerial1.Device+
                                    txtp(011)+
                                    BaudRate,cl_dark_green);
  end
  else begin
    ConnectButton.Caption:=txtp(003);
    PortConnected:=false;

    LazSerial1.Close;

    Image_gn.Visible:=false;
    Image_rt.Visible:=true;
    ListBox_Messages_Add_Item_Color(txtp(004),cl_dark_red);

  {  ListBox_Messages.Items.Add('--- Port wurde getrennt');   }

  end;

  wdos_Drive.Allow_Save:=true;

end; { procedure TForm_Console.Port_Connect }




procedure TForm_Console.ConnectButtonClick(Sender: TObject);
begin
  Port_Connect;
end; { procedure TForm_Console.ConnectButtonClick }





// **************************************
// **** Geraeteverwaltung
// **************************************

procedure TForm_Console.CheckBox_GV_D7_VIDEOChange(Sender: TObject);
begin

  if CheckBox_GV_D7_VIDEO.Checked then
    DEVICE_VECTOR_Byte:=DEVICE_VECTOR_Byte or  %10000000
  else
    DEVICE_VECTOR_Byte:=DEVICE_VECTOR_Byte and %01111111;

end; { procedure TForm_Console.CheckBox_GV_B7_CONOUTChange }





procedure TForm_Console.CheckBox_GV_D6_CONINChange(Sender: TObject);
begin

  if CheckBox_GV_D6_CONIN.Checked then
    DEVICE_VECTOR_Byte:=DEVICE_VECTOR_Byte or  %01000000
  else
    DEVICE_VECTOR_Byte:=DEVICE_VECTOR_Byte and %10111111;

end; { procedure TForm_Console.CheckBox_GV_B6_CONINChange }




procedure TForm_Console.CheckBox_GV_D5_LISTChange(Sender: TObject);
begin

  if CheckBox_GV_D5_LIST.Checked then
    DEVICE_VECTOR_Byte:=DEVICE_VECTOR_Byte or  %00100000
  else
    DEVICE_VECTOR_Byte:=DEVICE_VECTOR_Byte and %11011111;

end; { procedure TForm_Console.CheckBox_GV_D5_LISTChange }




procedure TForm_Console.CheckBox_GV_D4_SOUNDChange(Sender: TObject);
begin

  if CheckBox_GV_D4_SOUND.Checked then
    DEVICE_VECTOR_Byte:=DEVICE_VECTOR_Byte or  %00010000
  else
    DEVICE_VECTOR_Byte:=DEVICE_VECTOR_Byte and %11101111;

end; { procedure TForm_Console.CheckBox_GV_D4_SOUNDChange }




procedure TForm_Console.CheckBox_GV_FDDChange(Sender: TObject);
begin

  if CheckBox_GV_FDD.Checked then
    DEVICE_VECTOR_Byte:=DEVICE_VECTOR_Byte or  %00001000
  else
    DEVICE_VECTOR_Byte:=DEVICE_VECTOR_Byte and %11110111;

end; { procedure TForm_Console.CheckBox_GV_D3_DRIVE }




procedure TForm_Console.CheckBox_GV_D2_HDDChange(Sender: TObject);
begin

  if CheckBox_GV_D2_HDD.Checked then
    DEVICE_VECTOR_Byte:=DEVICE_VECTOR_Byte or  %00000100
  else
    DEVICE_VECTOR_Byte:=DEVICE_VECTOR_Byte and %11111011;

end; { procedure TForm_Console.CheckBox_GV_D2_READER }






procedure TForm_Console.CheckBox_GV_D1_RTCChange(Sender: TObject);
begin

  if CheckBox_GV_D1_RTC.Checked then
    DEVICE_VECTOR_Byte:=DEVICE_VECTOR_Byte or  %00000010
  else
    DEVICE_VECTOR_Byte:=DEVICE_VECTOR_Byte and %11111101;

end; { procedure TForm_Console.CheckBox_GV_D1_RTCChange }






procedure TForm_Console.BitBtn_Print_SaveClick(Sender: TObject);
begin
  PRINT_File.SaveToFile(Program_File_Path+PRINT_File_Folder+path_separator+PRINT_File_Name);
end; { procedure TForm_Console.BitBtn_Print_SaveClick }






procedure TForm_Console.BitBtn_Drive_SaveClick(Sender: TObject);
begin
  wdos_Drive.Save_Drives;
  ListBox_Messages_Add_Item_Color(txtp(010),cl_dark_green);
end; { procedure TForm_Console.BitBtn_Drive_SaveClick }





procedure TForm_Console.BitBtn_Save_ScreenClick(Sender: TObject);
begin
  Form_CONS.Save_Screen;
end; { procedure TForm_Console.BitBtn_Save_ScreenClick }

procedure TForm_Console.BitBtn_Terminal_SaveClick(Sender: TObject);
begin

end;




procedure TForm_Console.Button_Font_applyClick(Sender: TObject);
begin
  GV_Font_Name:=ComboBox_Font_Namen.Items[ComboBox_Font_Namen.ItemIndex];
  Form_CONS.redraw_Form;
end; { procedure TForm_Console.Button_Font_applyClick }







// Language / Sprache
// German Deutsch de

procedure TForm_Console.CheckBox_lang_enChange(Sender: TObject);
begin

   if not Language_Init then begin

     if CheckBox_lang_en.Checked then begin
       CheckBox_lang_de.Checked:=false;
       lang_var:=lang_en;
                    {
       ListBox_Messages_Add_Item_Color('Sprache: Englisch'+
                                    txtp(060),cl_dark_green);
                                       }
     end;

   end;

end;







procedure TForm_Console.CheckBox_lang_deChange(Sender: TObject);
begin

   if not Language_Init then begin

     if CheckBox_lang_de.Checked then begin
       CheckBox_lang_en.Checked:=false;
       lang_var:=lang_de;
                   {
       ListBox_Messages_Add_Item_Color('Sprache: Deutsch'+
                                    txtp(060),cl_dark_green);
                                     }
     end;

   end;


end;









// *** DISK_MONITOR ***



procedure TForm_Console.DISK_MONITOR_OFF;
begin
  LED_GE.Visible:=true;
  LED_GN.Visible:=false;
  LED_RT.Visible:=false;

  LABEL_DISK.Visible:=false;
  Label_LBA.Visible:=false;


end; { procedure TForm_Console.DISK_MONITOR_OFF }





procedure TForm_Console.DISK_MONITOR_READ;
var
  Drive_Letter_Integer : Integer;
  Drive_Letter_Char : Char;
begin

  LED_GE.Visible:=false;
  LED_GN.Visible:=true;
  LED_RT.Visible:=false;

  if VAR_DISKNO<$80 then
    Drive_Letter_Integer:=ORD('A')+VAR_DISKNO
  else
    Drive_Letter_Integer:=ORD('C')+VAR_DISKNO-$80;

  Drive_Letter_Char:=CHR(Drive_Letter_Integer);
  LABEL_DISK.Caption:=Drive_Letter_Char;

  LABEL_LBA.Caption:=IntToStr(VAR_LBA);

  LABEL_DISK.Visible:=true;
  LABEL_LBA.Visible:=true;

  Timer2.Enabled:=true;

end; { procedure TForm_Console.DISK_MONITOR_READ }






procedure TForm_Console.DISK_MONITOR_WRITE;
var
  Drive_Letter_Integer : Integer;
  Drive_Letter_Char : Char;
begin

  LED_GE.Visible:=false;
  LED_GN.Visible:=false;
  LED_RT.Visible:=true;

  if VAR_DISKNO<$80 then
    Drive_Letter_Integer:=ORD('A')+VAR_DISKNO
  else
    Drive_Letter_Integer:=ORD('C')+VAR_DISKNO-$80;

  Drive_Letter_Char:=CHR(Drive_Letter_Integer);
  LABEL_DISK.Caption:=Drive_Letter_Char;

  LABEL_LBA.Caption:=IntToStr(VAR_LBA);

  LABEL_DISK.Visible:=true;
  LABEL_LBA.Visible:=true;

  Timer2.Enabled:=true;

end; { procedure TForm_Console.DISK_MONITOR_WRITE }






// *** READ / WRITE ***






procedure TForm_Console.WRITE_TO_LIST(DatenByte : Byte);
begin
  PRINT_File.Write(DatenByte,1);
end; { procedure TForm_Console.WRITE_TO_LIST }





// *********************************************
//   DOS
// *********************************************




procedure TForm_Console.Delay(Milliseconds: Integer);

{ Nicht blockierende Verzoegerung um die angegebene Anzahl Millisekunden.
  Waehrend der Wartezeit bleibt die GUI bedienbar (Application.ProcessMessages)
  und ein Programmende (Application.Terminated) wird beruecksichtigt.

  Es gibt zwei funktionsgleiche Implementierungen:
    - Windows: ueber die Windows-API (CreateEvent / MsgWaitForMultipleObjects)
    - Linux/Unix: ueber GetTickCount64 + Application.ProcessMessages }

{$IFDEF MSWINDOWS}

// ----- Variante fuer Windows -----
var
  Tick: DWord;
  Event: THandle;
begin
 
  Event := CreateEvent(nil, False, False, nil);
  try
    Tick := GetTickCount + DWord(Milliseconds);
    while (Milliseconds > 0) and
          (MsgWaitForMultipleObjects(1, Event, False, Milliseconds, QS_ALLINPUT) <> WAIT_TIMEOUT) do
    begin
      Application.ProcessMessages;
      if Application.Terminated then Exit;
      Milliseconds := Tick - GetTickcount;
    end;
  finally
    CloseHandle(Event);
  end;
 
end; { procedure TForm_Console.Delay - Windows }

{$ELSE}

// ----- Variante fuer Linux / Unix -----
var
  Target_Tick : QWord;   // Zielzeitpunkt in Millisekunden (GetTickCount64)
begin

  if Milliseconds <= 0 then
    Exit;

  Target_Tick := GetTickCount64 + QWord(Milliseconds);

  while GetTickCount64 < Target_Tick do
  begin
    Application.ProcessMessages;        // GUI reagiert weiter
    if Application.Terminated then Exit;
    Sleep(1);                           // CPU-Last gering halten
  end;

end; { procedure TForm_Console.Delay - Linux/Unix }

{$ENDIF}







procedure TForm_Console.LBA_Sector_read_from_UART;
var
  B_Counter : Integer;
  Row : String;
  I_POS : LongInt;
  C_Counter, D_Counter : Integer;


  ar : array[0..550] of Byte;
  PT : ^Byte;


begin

  if not PortConnected then
    Port_Connect;

  DISK_MONITOR_READ;


  I_POS:=VAR_LBA*512;


  if LOG_READ then begin

    ListBox_Messages_Add_Item_Color(
      'DRIVE -> I_POS='+IntToHex(I_POS,6)+'H', cl_dark_brown);

    ListBox_Messages_Add_Item_Color(
      'LBA='+IntToStr(VAR_LBA)+
      ' DISKNO='+IntToStr(VAR_DISKNO), cl_dark_brown);

  end;

  PT:=ar;


  if VAR_DISKNO<$80 then begin
    wdos_Drive.IMAGE_FDD.DISK_IMG.Position:=I_POS;
    wdos_Drive.IMAGE_FDD.DISK_IMG.Read(ar,512);
  end
  else begin
    wdos_Drive.IMAGE_HDD.DISK_IMG.Position:=I_POS;
    wdos_Drive.IMAGE_HDD.DISK_IMG.Read(ar,512);
  end;


  LazSerial1.WriteBuffer(PT^,512);


  Delay(1);


  if LOG_READ then begin

    Row:='LOG_READ= '+IntToHex(VAR_LBA,4)+'H';
    ListBox_Messages_Add_Item_Color(Row, cl_dark_brown);

    D_Counter:=0;

    for C_Counter:=0 to 31 do begin

      Row:=IntToHex(D_Counter,4)+'H = ';

      for B_Counter:=0 to 15 do begin

        Row:=Row+IntToHex(ar[D_Counter],2)+'H ';
        INC(D_Counter);

      end;

      ListBox_Messages_Add_Item_Color(Row, cl_dark_brown);

    end;

  end;

  Timer2.Enabled:=true;

end; { procedure TForm_Console.LBA_Sector_read_from_UART }







procedure TForm_Console.LBA_Sector_write_to_UART(WR_Line : String);
var
  B_Counter, VAR_WR_LFD_NR : Integer;
//  IL_POS : Integer;
  B_Byte : Byte;
  I_POS : LongInt;
  S_Number : String;
begin
  if not PortConnected then
    Port_Connect;

  S_Number := Copy(WR_Line,1,2);
  VAR_WR_LFD_NR := StrToIntDef('$'+S_Number,0);

  I_POS:=VAR_LBA*512+(VAR_WR_LFD_NR*16);


  if VAR_WR_LFD_NR=0 then begin
    DISK_MONITOR_WRITE;

    if LOG_WRITE then begin

      ListBox_Messages_Add_Item_Color('LBA='+IntToStr(VAR_LBA)+' Dsk='+IntToStr(VAR_DISKNO),
                           cl_dark_brown);

      ListBox_Messages_Add_Item_Color(
          'DRIVE -> I_POS='+IntToHex(I_POS,6)+'H', cl_dark_brown);

    end;

  end;


  if LOG_WRITE then begin
    ListBox_Messages_Add_Item_Color('<< WRITE='+WR_Line,cl_dark_brown);
  end;





  if VAR_DISKNO<$80 then begin

    wdos_Drive.IMAGE_FDD.DISK_IMG.Position:=I_POS;

    for B_Counter:=0 to 15 do begin
      S_Number := Copy(WR_Line,3+(B_Counter*2),2);
      B_Byte := StrToIntDef('$'+S_Number,0);
      wdos_Drive.IMAGE_FDD.DISK_IMG.Write(B_Byte,1);
    end; { for B_Counter:=0 to 15 do }

  end
  else begin

    wdos_Drive.IMAGE_HDD.DISK_IMG.Position:=I_POS;

    for B_Counter:=0 to 15 do begin
      S_Number := Copy(WR_Line,3+(B_Counter*2),2);
      B_Byte := StrToIntDef('$'+S_Number,0);
      wdos_Drive.IMAGE_HDD.DISK_IMG.Write(B_Byte,1);
    end; { for B_Counter:=0 to 15 do }

  end; // if VAR_DISKNO<$80 then


  if (VAR_WR_LFD_NR=31) then begin
    Timer2.Enabled:=true;
  end; { if (VAR_WR_LFD_NR=31) then }


end; { procedure TForm_Console.LBA_Sector_write_to_UART }










procedure TForm_Console.send_Date_and_Time;
var
  Line_A, Line_B : String;
begin

  Line_A:=DateToStr(Now);
  Line_B:='D'+Copy(Line_A,1,2)+Copy(Line_A,4,2)+Copy(Line_A,7,4);
  Line_A:=TimeToStr(Time);
  Line_B:=Line_B+Copy(Line_A,1,2)+Copy(Line_A,4,2)+Copy(Line_A,7,2);

  LazSerial1.WriteData(Line_B+CRLF);

  ListBox_Messages_Add_Item_Color(txtp(012)+Line_B+')',cl_dark_brown);

end; { procedure TForm_Console.send_Date_and_Time }









procedure TForm_Console.send_CONIN;
var
  CI_Line : String;
  CI_Word : Word;
begin

  CI_Word:=Form_CONS.read_key;
  CI_Line:='I'+IntToHex(CI_Word,4); // I1E01 = I + 1E01H -> Tastaturwert
  LazSerial1.WriteData(CI_Line+CRLF);

  if LOG_CONIN then
    ListBox_Messages_Add_Item_Color(txtp(013)+CI_Line+')',cl_dark_brown);

end; { procedure TForm_Console.send_CONIN }










procedure TForm_Console.send_CONST;
var
  CI_Line : String;
  CI_Byte : Byte;

begin

  CI_Byte:=Form_CONS.read_key_stat;

  CI_Line:='J'+IntToHex(CI_Byte,2); // JFF = J + FF oder 00
  LazSerial1.WriteData(CI_Line+CRLF);

end; { procedure TForm_Console.send_CONST }






// N BT XH XL YH YL = N + 10 = 11
procedure TForm_Console.send_MOUSE(SM_Param : Char);


  procedure MouseInit;
  begin

    with Form_CONS do begin

      RMouse.Button:=0;
      RMouse.X:=0;
      RMouse.Y:=0;
      RMouse.visible:=false;
      RMouse.X_OLD:=MOUSE_OUT;
      RMouse.Y_OLD:=MOUSE_OUT;

    end;

  end; { procedure MouseInit }


  procedure ShowMouse;
  begin

    with Form_CONS do begin

   //   RMouse.Button:=0;
   //   RMouse.X:=0;
   //   RMouse.Y:=0;
      RMouse.visible:=true;
 //     RMouse.X_OLD:=MOUSE_OUT;
  //    RMouse.Y_OLD:=MOUSE_OUT;

    end;

  end; { procedure ShowMouse }


  procedure HideMouse;
  var
    M1_Attr, M2_Attr : Byte;
  begin

    with Form_CONS do begin

  //    M1_Attr:=CharMatrix[RMouse.Y_OLD div 8,RMouse.X_OLD div 8].Attribute;
      M2_Attr:=M1_Attr shr 4;
      M1_Attr:=M1_Attr shl 4;
      M2_Attr:=M1_Attr+M2_Attr;
  //    CharMatrix[RMouse.Y_OLD div 8,RMouse.X_OLD div 8].Attribute:=M2_Attr;

 //     RMouse.Button:=0;
 //     RMouse.X:=0;
//      RMouse.Y:=0;
      RMouse.visible:=false;
   //   RMouse.X_OLD:=MOUSE_OUT;
  //    RMouse.Y_OLD:=MOUSE_OUT;

    end;

  end; { procedure HideMouse }


  procedure ReadMouse;
  var
    MO_Line : String;
  begin

    MO_Line:='N'+IntToHex(Form_CONS.RMouse.Button,2)+
                  IntToHex(Form_CONS.RMouse.X,4)+
                  IntToHex(Form_CONS.RMouse.Y,4);
    LazSerial1.WriteData(MO_Line+CRLF);

    if CheckBox_LOG_MOUSE.Checked then begin
      ListBox_Messages_Add_Item_Color('<< MOUSE='+MO_Line,cl_dark_brown);
    end;

  end; { procedure ReadMouse }



begin

  case SM_Param of

    'i' : MouseInit;

    's' : ShowMouse;

    'h' : HideMouse;

    'r' : ReadMouse;

  else
    ListBox_Messages_Add_Item_Color(txtp(014)+SM_Param+txtp(015),cl_dark_red);
  end;

end; { procedure TForm_Console.send_MOUSE }







procedure TForm_Console.send_DEVICE_VECTOR;
var
  DV_Line : String;

  {
    Konfiguration WHO_ARE_YOU - Byte
    D7 - CONOUT
    D6 - CONIN
    D5 - LIST
    D4 - SOUND
    D3 - DIVE
    D2 - READER
    D1 - N.N.
    D0 - N.N.
  }

begin

  DV_Line:='H'+IntToHex(DEVICE_VECTOR_Byte,2); // = H + XX
  LazSerial1.WriteData(DV_Line+CRLF);


  if LOG_DEVICE_VECTOR then begin
    ListBox_Messages_Add_Item_Color('<< DEVICE_VECTOR='+
                                     IntToBin(DEVICE_VECTOR_Byte,8)+'B',cl_dark_brown);
  end;


end; { procedure TForm_Console.send_DEVICE_VECTOR }













procedure TForm_Console.DEBUG_Register(DEBUG_Line : String);
var

  DBG_Token, DBG_Register,
  DBG_INT_01, DBG_INT_02, DBG_INT_03 : String;
  DBG_Number : Byte;




  function HexToBin(HEX_String : String) : String;
  var
    BIN_String : String;
    BIN_Counter : Integer;
    BIN_Byte, BIN_Selector : Byte;
  begin
    if Length(HEX_String)>1 then begin
      BIN_String:='';
      BIN_Byte:=StrToIntDef('$'+HEX_String[1]+HEX_String[2],0);


      // SZ A P C
      BIN_Byte:=BIN_Byte and %11010101;


      for BIN_Counter:=1 to 8 do begin
        BIN_Selector:=BIN_Byte and %10000000;
        if BIN_Selector=0 then
          BIN_String:=BIN_String+'0'
        else
          BIN_String:=BIN_String+'1';

        BIN_Byte:=BIN_Byte shl 1;

      end; { for BIN_Counter:=1 to 8 do }

    end
    else
      BIN_String:='XXXXXXXX';

    Result:=BIN_String;
  end; { function HexToBin }





  // INT OK
  procedure PRG_DBG_Number_01;
  begin

    DBG_Token:=DEBUG_Line[3]+DEBUG_Line[4];
    DBG_INT_01:='DEBUG INT='+DBG_Token+'H  FKT='+
                Copy(DEBUG_Line,5,2)+'H aufgerufen';


{
cl_green_INT10  = $00A5FF; // Orange FFA500
cl_green_INT13  = $FF0000; // Blue   0000FF
cl_green_INT16  = $008080; // Olive  808000
cl_green_INT1A  = $00D7FF; // Gold   FFD700
}

    CASE DBG_Token of

      '10' : INT_Color:=cl_green_INT10;
      '13' : INT_Color:=cl_green_INT13;
      '16' : INT_Color:=cl_green_INT16;
      '1A' : INT_Color:=cl_green_INT1A;

    else
      INT_Color:=cl_dark_green;
    end;


    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//    if INT_Color=cl_green_INT10 then begin


    DBG_INT_02:=' ---> AX='+Copy(DEBUG_Line,5,4);
    DBG_Register:=' BX='+Copy(DEBUG_Line,9,4);
    DBG_INT_02:=DBG_INT_02+DBG_Register;
    DBG_Register:=' CX='+Copy(DEBUG_Line,13,4);
    DBG_INT_02:=DBG_INT_02+DBG_Register;
    DBG_Register:=' DX='+Copy(DEBUG_Line,17,4);
    DBG_INT_02:=DBG_INT_02+DBG_Register;
    DBG_Register:='    SZ_A_P_C';
    DBG_INT_02:=DBG_INT_02+DBG_Register;

    DBG_INT_03:=' ---> BP='+Copy(DEBUG_Line,23,4);
    DBG_Register:=' SI='+Copy(DEBUG_Line,27,4);
    DBG_INT_03:=DBG_INT_03+DBG_Register;
    DBG_Register:=' DI='+Copy(DEBUG_Line,31,4);
    DBG_INT_03:=DBG_INT_03+DBG_Register;
    DBG_Register:=' ES='+Copy(DEBUG_Line,35,4);
    DBG_INT_03:=DBG_INT_03+DBG_Register;
    DBG_Register:=Copy(DEBUG_Line,21,2);
    DBG_Register:=' FL='+HexToBin(DBG_Register)+' '+DBG_Register+'H';
    DBG_INT_03:=DBG_INT_03+DBG_Register;

    ListBox_Messages_Add_Item_Color(DBG_INT_01,INT_Color);
    ListBox_Messages_Add_Item_Color(DBG_INT_02,INT_Color);
    ListBox_Messages_Add_Item_Color(DBG_INT_03,INT_Color);

 //   end;


  end; { procedure PRG_DBG_Number_01 }







  // INT NO
  procedure PRG_DBG_Number_02;
  begin

    DBG_Token:=DEBUG_Line[3]+DEBUG_Line[4];
    DBG_INT_01:='*** FEHLER!!! INT='+DBG_Token+'H  FKT='+
                Copy(DEBUG_Line,5,2)+'H nicht gefunden ***';

    DBG_INT_02:='......AX='+Copy(DEBUG_Line,5,4);
    DBG_Register:=' BX='+Copy(DEBUG_Line,9,4);
    DBG_INT_02:=DBG_INT_02+DBG_Register;
    DBG_Register:=' CX='+Copy(DEBUG_Line,13,4);
    DBG_INT_02:=DBG_INT_02+DBG_Register;
    DBG_Register:=' DX='+Copy(DEBUG_Line,17,4);
    DBG_INT_02:=DBG_INT_02+DBG_Register;
    DBG_Register:='    SZ_A_P_C';
    DBG_INT_02:=DBG_INT_02+DBG_Register;

    DBG_INT_03:='......BP='+Copy(DEBUG_Line,23,4);
    DBG_Register:=' SI='+Copy(DEBUG_Line,27,4);
    DBG_INT_03:=DBG_INT_03+DBG_Register;
    DBG_Register:=' DI='+Copy(DEBUG_Line,31,4);
    DBG_INT_03:=DBG_INT_03+DBG_Register;
    DBG_Register:=' ES='+Copy(DEBUG_Line,35,4);
    DBG_INT_03:=DBG_INT_03+DBG_Register;
    DBG_Register:=Copy(DEBUG_Line,21,2);
    DBG_Register:=' FL='+HexToBin(DBG_Register)+' '+DBG_Register+'H';
    DBG_INT_03:=DBG_INT_03+DBG_Register;

    ListBox_Messages_Add_Item_Color(DBG_INT_01,cl_dark_red);
    ListBox_Messages_Add_Item_Color(DBG_INT_02,cl_dark_red);
    ListBox_Messages_Add_Item_Color(DBG_INT_03,cl_dark_red);

  end; { procedure PRG_DBG_Number_02 }




  // INT
  procedure PRG_DBG_Number_03;
  begin

  //  if INT_Color=cl_green_INT10 then begin

    DBG_INT_02:=' <--- AX='+Copy(DEBUG_Line,5,4);
    DBG_Register:=' BX='+Copy(DEBUG_Line,9,4);
    DBG_INT_02:=DBG_INT_02+DBG_Register;
    DBG_Register:=' CX='+Copy(DEBUG_Line,13,4);
    DBG_INT_02:=DBG_INT_02+DBG_Register;
    DBG_Register:=' DX='+Copy(DEBUG_Line,17,4);
    DBG_INT_02:=DBG_INT_02+DBG_Register;
    DBG_Register:='    SZ_A_P_C';
    DBG_INT_02:=DBG_INT_02+DBG_Register;

    DBG_INT_03:=' <--- BP='+Copy(DEBUG_Line,23,4);
    DBG_Register:=' SI='+Copy(DEBUG_Line,27,4);
    DBG_INT_03:=DBG_INT_03+DBG_Register;
    DBG_Register:=' DI='+Copy(DEBUG_Line,31,4);
    DBG_INT_03:=DBG_INT_03+DBG_Register;
    DBG_Register:=' ES='+Copy(DEBUG_Line,35,4);
    DBG_INT_03:=DBG_INT_03+DBG_Register;
    DBG_Register:=Copy(DEBUG_Line,21,2);
    DBG_Register:=' FL='+HexToBin(DBG_Register)+' '+DBG_Register+'H';
    DBG_INT_03:=DBG_INT_03+DBG_Register;

    ListBox_Messages_Add_Item_Color(DBG_INT_02,INT_Color);
    ListBox_Messages_Add_Item_Color(DBG_INT_03,INT_Color);

 //   end;

  end; { procedure PRG_DBG_Number_03 }




  procedure PRG_DBG_Number_04;
  begin
    // DE DE AD AD AD AD D0 D0
    DBG_INT_01:='ADR('+Copy(DEBUG_Line,3,4)+') '+
                 Copy(DEBUG_Line,7,2)+
                 Copy(DEBUG_Line,9,2)+
                 Copy(DEBUG_Line,11,2)+
                 Copy(DEBUG_Line,13,2)+
                 Copy(DEBUG_Line,15,2)+
                 Copy(DEBUG_Line,17,2)+
                 Copy(DEBUG_Line,19,2)+
                 Copy(DEBUG_Line,21,2);

    ListBox_Messages_Add_Item_Color(DBG_INT_01,cl_dark_green);

  end; { procedure PRG_DBG_Number_04 }




  // Rueck
  procedure PRG_DBG_Number_05;
  begin

 //   if INT_Color=cl_green_INT10 then begin

    DBG_INT_02:=' <--- AX='+Copy(DEBUG_Line,5,4);
    DBG_Register:=' BX='+Copy(DEBUG_Line,9,4);
    DBG_INT_02:=DBG_INT_02+DBG_Register;
    DBG_Register:=' CX='+Copy(DEBUG_Line,13,4);
    DBG_INT_02:=DBG_INT_02+DBG_Register;
    DBG_Register:=' DX='+Copy(DEBUG_Line,17,4);
    DBG_INT_02:=DBG_INT_02+DBG_Register;
    DBG_Register:='    SZ_A_P_C';
    DBG_INT_02:=DBG_INT_02+DBG_Register;

    DBG_INT_03:=' <--- BP='+Copy(DEBUG_Line,23,4);
    DBG_Register:=' SI='+Copy(DEBUG_Line,27,4);
    DBG_INT_03:=DBG_INT_03+DBG_Register;
    DBG_Register:=' DI='+Copy(DEBUG_Line,31,4);
    DBG_INT_03:=DBG_INT_03+DBG_Register;
    DBG_Register:=' ES='+Copy(DEBUG_Line,35,4);
    DBG_INT_03:=DBG_INT_03+DBG_Register;
    DBG_Register:=Copy(DEBUG_Line,21,2);
    DBG_Register:=' FL='+HexToBin(DBG_Register)+' '+DBG_Register+'H';
    DBG_INT_03:=DBG_INT_03+DBG_Register;

    ListBox_Messages_Add_Item_Color(DBG_INT_02,INT_Color);
    ListBox_Messages_Add_Item_Color(DBG_INT_03,INT_Color);

 //   end;

  end; { procedure PRG_DBG_Number_05 }




  procedure PRG_DBG_Number_XX;
  begin

    ListBox_Messages_Add_Item_Color('*** Debug Register='+
                      DEBUG_Line,cl_dark_red);

  end; { procedure PRG_DBG_Number_XX }


begin

  DBG_Token:=DEBUG_Line[1]+DEBUG_Line[2];
  DBG_Number:=StrToIntDef(DBG_Token,0);

  if CheckBox_LOG_DEBUG.Checked then begin

    case DBG_Number of

      1 : PRG_DBG_Number_01;

      2 : PRG_DBG_Number_02;

      3 : PRG_DBG_Number_03;

      4 : PRG_DBG_Number_04;

      5 : PRG_DBG_Number_05;

    else

      PRG_DBG_Number_XX;

    end; // case DBG_Number of

  end; //  if CheckBox_LOG_DEBUG.Checked then

end; { procedure TForm_Console.DEBUG_Register }








procedure TForm_Console.send_VIDEO_GET_Parameter(DB_Routine : Byte);
var
  SC_Line : String;
  SC_Parameter_01, SC_Parameter_02 : Integer;
  CaA_Character : TCharAttr;



begin

  case DB_Routine of

    VIDEO_GET_CURSOR_POS :
      begin
        SC_Parameter_01:=Form_CONS.MCursor.Column;
        SC_Parameter_02:=Form_CONS.MCursor.Row;
             {
        ListBox_Messages_Add_Item_Color('VIDEO_GET_CURSOR_POS: Column='+
             IntToStr(SC_Parameter_01)+' Row='+
             IntToStr(SC_Parameter_02),
             cl_dark_blue);
                      }
     end; // VIDEO_GET_CURSOR_POS



    VIDEO_GET_ChrAtt_CurPos :
      begin
        CaA_Character:=Form_CONS.READ_CHARACTER_AND_ATTRIBUTE_AT_CURSOR_POSITION;
        SC_Parameter_01:=CaA_Character.Character;
        SC_Parameter_02:=CaA_Character.Attribute;

        ListBox_Messages_Add_Item_Color('VIDEO_RD_Chr_Att_CurPos: Character='+
             IntToHex(SC_Parameter_01,2)+' Attribute='+
             IntToHex(SC_Parameter_02,2),
             cl_dark_blue);

      end; // VIDEO_RD_Chr_Att_CurPos

  else

    ListBox_Messages_Add_Item_Color(txtp(016)+
                      IntToHex(DB_Routine,2)+txtp(017),
                         cl_dark_red);

  end; { case DB_Routine of }


  SC_Line:='G'+IntToHex(SC_Parameter_01,2)+
                IntToHex(SC_Parameter_02,2);

  LazSerial1.WriteData(SC_Line+CRLF);

end; { procedure TForm_Console.send_VIDEO_GET_Parameter }






// kopiere TeilVideoRAM
// q + SA 01 02 03 ... 20 = 1 + 21*2 = 43
procedure TForm_Console.Write_VIDEO_Column_Section(Row : String);
var
  Column_Section, SA_Counter,
  SA_Row, SA_Column,
  SA_Offset : Integer;
  SA_Character : TCharAttr;
  ein_Byte : Byte;
  SA_String : String;

begin

  Form_CONS.Timer_CURSOR_Enabled_false;

  if not PortConnected then
    Port_Connect;

  SA_String := Copy(Row,1,2);


  SA_Counter := StrToIntDef('$'+SA_String,0); // 0..199
  SA_Row := SA_Counter DIV 8;          // 0..24=25
  Column_Section := SA_Counter MOD 8; // 0..7


{
  ListBox_Messages_Add_Item_Color('VIDEO SA ='+Row,
                            cl_dark_blue);   }


  for SA_Offset:=1 to 10 do begin

    SA_String:=Copy(Row,(SA_Offset*4)-1,2);  //  SA01020304  1*4=4-1=3 - "01"
    ein_Byte:=StrToIntDef('$'+SA_String,0);
    SA_Character.Character:=ein_Byte;
    SA_String:=Copy(Row,(SA_Offset*4)+1,2);  //  SA01020304  1*4=4+1=5 - "02"
    ein_Byte:=StrToIntDef('$'+SA_String,0);
    SA_Character.Attribute:=ein_Byte;

    SA_Column:=(Column_Section*10)+SA_Offset-1;
    Form_CONS.CharMatrix[SA_Row,SA_Column]:=SA_Character;

  end; { for SA_Offset:=1 to 10 do }

  Form_CONS.Timer_CURSOR_Enabled_true;

end; { procedure TForm_Console.Write_VIDEO_Column_Section }









procedure TForm_Console.LazSerial1RxData(Sender: TObject);
var
  Command_Char : Char;
  Received_Line : String;
  POS_KA : Integer;
  DatenByte_01,
  DatenByte_02, DatenByte_03 : Byte;
  SER_BS_Character : TCharAttr;



begin


  ReadCOM:=ReadCOM+LazSerial1.ReadData;



  // Anfangsinitialisierung - ReadCOM leeren
  POS_KA:=Pos('@',ReadCOM);
  if POS_KA>0 then begin

    ReadCOM := '';
    ListBox_Messages.Items.Clear;

    Form_CONS.clear_KeyBuffer;

    ListBox_Messages_Add_Item_Color(txtp(005),cl_dark_blue);


  end; { if POS_KA>0 then }



  // Anfangsinitialisierung - ReadCOM leeren

  POS_KA:=Pos(#0,ReadCOM);
  if POS_KA>0 then begin

    // CheckBox_XOFF
    if CheckBox_XOFF.Checked then begin

      LazSerial1.WriteData(XOFF);
      ListBox_Messages_Add_Item_Color(txtp(006),cl_dark_blue);

    end;

    ReadCOM := '';

  end; { if POS_KA>0 then }




  while Pos(CRLF,ReadCOM)>0 do begin { Befehlszeile wurde vollstaendig empfangen }

        if Length(ReadCOM)>Length(CRLF) then begin
          Command_Char:=ReadCOM[1];
          Delete(ReadCOM,1,1);
          case Command_Char of




            // READ und WRITE DOS Sektor


            // b NR D32 = b + 34 = 35
            // b NR D00 D01 D02 D03 D04 D05 D06 D07 D08 D09 D10 D11 D12 D13 D14 D15
            //      D16 D17 D18 D19 D20 D21 D22 D23 D24 D25 D26 D27 D28 D29 D30 D31
            // uC sendet das Kommando 'b'
            // dann folgen 2 Byte Hexacode (als Char) fuer die laufende NR des Codeabschnittes
            // dann folgen 32*2 Byte Hexacode (als Char) fuer die 32 Datenbytes
            'b' : begin // LBA_Sector_write_to_UART
                    if Pos(CRLF,ReadCOM)=35 then begin
                      Received_Line:=Copy(ReadCOM,1,34);
                      Delete(ReadCOM,1,34+Length(CRLF));
                      LBA_Sector_write_to_UART(Received_Line);
                    end
                    else
                      ListBox_Messages_Add_Item_Color(
                         '*** Fehler: zu viele Parameter in den Daten ('+ReadCOM+') ***',
                         cl_dark_red);

                  end; { 'b' }



            // uC sendet das Kommando 'd'
            // keine weiteren Zeichen als Uebergabeparameter
            // die Prozedur sendet
            'd' : begin // Datum und Zeit
                    if Pos(CRLF,ReadCOM)=1 then begin
                      Delete(ReadCOM,1,Length(CRLF));
                      send_Date_and_Time;
                    end
                    else
                      ListBox_Messages_Add_Item_Color(
                         '*** Fehler: zu viele Parameter in den Daten ('+ReadCOM+') ***',
                         cl_dark_red);

                  end; { 'd' }



            // uC sendet das Kommando 'f'
            // dann folgen 2 Byte Hexacode (als Char) fuer das Video-Send-Kommando
            // dann folgen 2 Byte Hexacode (als Char) fuer das erste Parameter-Byte
            // dann folgen 2 Byte Hexacode (als Char) fuer das zweite Parameter-Byte
            'f' : begin // Video Send Routine = f CO P1 P2
                    if Pos(CRLF,ReadCOM)=7 then begin
                      Received_Line:=Copy(ReadCOM,1,2);
                      DatenByte_01:=StrToIntDef('$'+Received_Line,0);
                      Received_Line:=Copy(ReadCOM,3,2);
                      DatenByte_02:=StrToIntDef('$'+Received_Line,0);
                      Received_Line:=Copy(ReadCOM,5,2);
                      DatenByte_03:=StrToIntDef('$'+Received_Line,0);
                      Delete(ReadCOM,1,6+Length(CRLF));

                      Form_CONS.Video_Send_Routine(DatenByte_01,
                              DatenByte_02, DatenByte_03);

                      if LOG_CONOUT then begin
                        ListBox_Messages_Add_Item_Color('Video Send Routine = f CO P1 P2=',
                                                         cl_dark_brown);

                        ListBox_Messages_Add_Item_Color('DatenByte_01='+
                                  IntToHex(DatenByte_01,2)+'H',cl_dark_brown);
                        ListBox_Messages_Add_Item_Color('DatenByte_02='+
                                  IntToHex(DatenByte_02,2)+'H',cl_dark_brown);
                        ListBox_Messages_Add_Item_Color('DatenByte_03='+
                                  IntToHex(DatenByte_03,2)+'H',cl_dark_brown);

                      end;

                    end
                    else
                      ListBox_Messages_Add_Item_Color(
                         '*** Fehler: zu viele Parameter in den Daten ('+ReadCOM+') ***',
                         cl_dark_red);

                  end; { 'f' }





            'g' : begin // Video Get Routine = g CO
                    if Pos(CRLF,ReadCOM)=3 then begin
                      Received_Line:=Copy(ReadCOM,1,2);
                      DatenByte_01:=StrToIntDef('$'+Received_Line,0);
                      Delete(ReadCOM,1,2+Length(CRLF));

                      send_VIDEO_GET_Parameter(DatenByte_01);

                    end
                    else
                      ListBox_Messages_Add_Item_Color(
                         '*** Fehler: zu viele Parameter in den Daten ('+ReadCOM+') ***',
                         cl_dark_red);

                  end; { 'g' }






            'h' : begin // DEVICE_VECTOR

                    if Pos(CRLF,ReadCOM)=1 then begin
                      Delete(ReadCOM,1,Length(CRLF));
                      send_DEVICE_VECTOR;
                    end
                    else
                      ListBox_Messages_Add_Item_Color(
                         '*** Fehler: zu viele Parameter in den Daten ('+ReadCOM+') ***',
                         cl_dark_red);

                  end; { 'h' }



            'i' : begin // CONIN

                    if Pos(CRLF,ReadCOM)=1 then begin
                      Delete(ReadCOM,1,Length(CRLF));
                      send_CONIN;
                    end
                    else
                      ListBox_Messages_Add_Item_Color(
                         '*** Fehler: zu viele Parameter in den Daten ('+ReadCOM+') ***',
                         cl_dark_red);

                  end; { 'i' }


            'j' : begin // CONST

                    if Pos(CRLF,ReadCOM)=1 then begin
                      Delete(ReadCOM,1,Length(CRLF));
                      send_CONST;
                    end
                    else
                      ListBox_Messages_Add_Item_Color(
                         '*** Fehler: zu viele Parameter in den Daten ('+ReadCOM+') ***',
                         cl_dark_red);

                  end; { 'j' }


            'l' : begin // LIST
                    if Pos(CRLF,ReadCOM)=3 then begin
                      Received_Line:=Copy(ReadCOM,1,2);
                      Delete(ReadCOM,1,2+Length(CRLF));
                      DatenByte_01:=StrToIntDef('$'+Received_Line,0);
                      WRITE_TO_LIST(DatenByte_01);
                    end
                    else
                      ListBox_Messages_Add_Item_Color(
                         '*** Fehler: zu viele Parameter in den Daten ('+ReadCOM+') ***',
                         cl_dark_red);

                  end; { 'l' }




            'm' : begin // DEBUG  m AR 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18
                        // m + 38 = 39

                    if Pos(CRLF,ReadCOM)=39 then begin
                      Received_Line:=Copy(ReadCOM,1,38);
                      Delete(ReadCOM,1,38+Length(CRLF));
                      DEBUG_Register(Received_Line);
                    end
                    else
                      ListBox_Messages_Add_Item_Color(
                         '*** Fehler: zu viele Parameter in den Daten ('+ReadCOM+') ***',
                         cl_dark_red);

                  end; { 'm' }



            'n' : begin // MOUSE

                    if Pos(CRLF,ReadCOM)=2 then begin
                      Received_Line:=Copy(ReadCOM,1,1);
                      Delete(ReadCOM,1,1+Length(CRLF));
                      send_MOUSE(Received_Line[1]);
                    end
                    else
                      ListBox_Messages_Add_Item_Color(
                         '*** Fehler: zu viele Parameter in den Daten ('+ReadCOM+') ***',
                         cl_dark_red);

                  end; { 'n' }








            'q' : begin // kopiere TeilVideoRAM
                        // q + SA 01 02 03 ... 20 = 1 + 21*2 = 43

                   if Pos(CRLF,ReadCOM)=43 then begin
                     Received_Line:=Copy(ReadCOM,1,42);
                     Delete(ReadCOM,1,42+Length(CRLF));
                     Write_VIDEO_Column_Section(Received_Line);
                   end
                   else
                     ListBox_Messages_Add_Item_Color(
                         '*** Fehler: zu viele Parameter in den Daten ('+ReadCOM+') ***',
                         cl_dark_red);

                  end; { 'q' }





            'r' : begin // LBA_Sector_read_from_UART = r LH LL DN = 1+6 = 7
                    if Pos(CRLF,ReadCOM)=7 then begin
                      // VAR_LBA, VAR_DISKNO
                      Received_Line:=Copy(ReadCOM,1,4);
                      VAR_LBA:=StrToIntDef('$'+Received_Line,0); // VAR_LBA
                      Received_Line:=Copy(ReadCOM,5,2);
                      VAR_DISKNO:=StrToIntDef('$'+Received_Line,0); // VAR_DISKNO
                      Delete(ReadCOM,1,6+Length(CRLF));

                      LBA_Sector_read_from_UART;

                    end
                    else
                      ListBox_Messages_Add_Item_Color(
                         '*** Fehler: zu viele Parameter in den Daten ('+ReadCOM+') ***',
                         cl_dark_red);

                  end; { 'r' }




            'w' : begin // LBA_Sector_write_to_UART = w LH LL DN = 1+6 = 7
                    // LEN_CMD_WRITE_LBA_SECTOR = 7
                    if Pos(CRLF,ReadCOM)=7 then begin
                      // VAR_LBA, VAR_DISKNO
                      Received_Line:=Copy(ReadCOM,1,4);
                      VAR_LBA:=StrToIntDef('$'+Received_Line,0); // VAR_LBA
                      Received_Line:=Copy(ReadCOM,5,2);
                      VAR_DISKNO:=StrToIntDef('$'+Received_Line,0); // VAR_DISKNO
                      Delete(ReadCOM,1,6+Length(CRLF));

                    end
                    else
                      ListBox_Messages_Add_Item_Color(txtp(018)+ReadCOM+') ***',cl_dark_red);

                  end; { 'w' }





            'x' : begin // Fehlernummer
                    if Pos(CRLF,ReadCOM)=3 then begin
                      Received_Line:=Copy(ReadCOM,1,2);
                      Delete(ReadCOM,1,2+Length(CRLF));
                      ListBox_Messages_Add_Item_Color(txtp(019)+
                                             Received_Line+txtp(020),cl_dark_red);
                    end
                    else
                      ListBox_Messages_Add_Item_Color(txtp(018)+ReadCOM+') ***',cl_dark_red);

                  end; { 'x' }


            'y' : begin  // Kommentare
                      Received_Line:=Copy(ReadCOM,1,Pos(CRLF,ReadCOM)-1);
                      Delete(ReadCOM,1,Pos(CRLF,ReadCOM)-1+Length(CRLF));
                      ListBox_Messages_Add_Item_Color('*** '+Received_Line,cl_dark_brown);
                  end; { 'y' }


          else
            ListBox_Messages_Add_Item_Color(txtp(021)+Command_Char+
                         ' ('+IntToHex(Ord(Command_Char),2)+txtp(022),cl_dark_red);


            if Pos(CRLF,ReadCOM)>0 then begin
              Delete(ReadCOM,1,Pos(CRLF,ReadCOM)-1+Length(CRLF));
            end
            else
              ReadCOM:='';


          end;

        end { if Length(ReadCOM)>Length(CRLF) then }
        else begin
          ListBox_Messages_Add_Item_Color(txtp(007),
                                           cl_dark_red);

          ListBox_Messages_Add_Item_Color(txtp(023)+ReadCOM+'>',cl_dark_red);

          Delay(500);

          INC(Error_Pass);
          if Error_Pass>20 then begin
            Port_Connect;
            ListBox_Messages.Items.SaveToFile('ListBox_Messages.txt');
            ReadCOM := '';
            ListBox_Messages_Add_Item_Color(txtp(008),
                                             cl_dark_red);
            ListBox_Messages_Add_Item_Color(txtp(009),
                                             cl_dark_red);
          end;



        end;


      end; { while Pos(CRLF,ReadCOM)>0 do }



end; { procedure TForm_Console.LazSerial1RxData }










procedure TForm_Console.Timer2Timer(Sender: TObject);
begin
  // DISK_MONITOR_SOUND;
  DISK_MONITOR_OFF;
  Timer2.Enabled:=false;
end; { procedure TForm_Console.Timer2Timer }










procedure TForm_Console.CheckBox_LOG_CONINChange(Sender: TObject);
begin
  LOG_CONIN:=CheckBox_LOG_CONIN.Checked;
end; { procedure TForm_Console.CheckBox_LOG_CONINChange }



procedure TForm_Console.CheckBox_LOG_CONOUTChange(Sender: TObject);
begin
  LOG_CONOUT:=CheckBox_LOG_CONOUT.Checked;
end; { procedure TForm_Console.CheckBox_LOG_CONOUTChange }



procedure TForm_Console.CheckBox_LOG_READChange(Sender: TObject);
begin
  LOG_READ:=CheckBox_LOG_READ.Checked;
end; { procedure TForm_Console.CheckBox_LOG_READChange }



procedure TForm_Console.CheckBox_LOG_WRITEChange(Sender: TObject);
begin
  LOG_WRITE:=CheckBox_LOG_WRITE.Checked;
end; { procedure TForm_Console.CheckBox_LOG_WRITEChange }






procedure TForm_Console.ComboBox_FontSize_query;
begin

  case ComboBox_FontSize.ItemIndex of

    0 : CONS_FontSize:=6;
    1 : CONS_FontSize:=8;
    2 : CONS_FontSize:=10;
    3 : CONS_FontSize:=14;
    4 : CONS_FontSize:=16;
    5 : CONS_FontSize:=18;
    6 : CONS_FontSize:=20;
    7 : CONS_FontSize:=22;
    8 : CONS_FontSize:=24;
    9 : CONS_FontSize:=26;

  else
    CONS_FontSize:=10;
  end;

  Form_CONS.MAIN_ComboBox_FontSize_Index:=ComboBox_FontSize.ItemIndex;

end; { procedure TForm_Console.ComboBox_FontSize_query }





procedure TForm_Console.ComboBox_FontSizeChange(Sender: TObject);
begin

  ComboBox_FontSize_query;
  Form_CONS.redraw_Form;

  ListBox_Messages_Add_Item_Color('*** FontSize auf '+IntToStr(CONS_FontSize)+' gesetzt',
                                           cl_dark_blue);

end; { procedure TForm_Console.ComboBox_FontSizeChange }





procedure TForm_Console.ComboBox_FontSize_change;
begin

  ComboBox_FontSize.ItemIndex:=Form_CONS.MAIN_ComboBox_FontSize_Index;
  ComboBox_FontSize_query;
  Form_CONS.redraw_Form;

  ListBox_Messages_Add_Item_Color('*** FontSize auf '+IntToStr(CONS_FontSize)+' gesetzt',
                                           cl_dark_blue);

end; { procedure TForm_Console.ComboBox_FontSize_change }








procedure TForm_Console.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

  if Shift = [] then
    case Key of
      27 : Form_Console.Close; // ESC
  end; { if Shift = [] then }

end; { procedure TForm_Console.FormKeyDown }




procedure TForm_Console.FormResize(Sender: TObject);
begin

  if Form_Console.Width>500 then
    Form_Console.Width:=500;

  if Form_Console.Width<500 then
    Form_Console.Width:=500;

  if Form_Console.Height<660 then
    Form_Console.Height:=660;

  if Form_Console.Height>1000 then
    Form_Console.Height:=1000;

end; { procedure TForm_Console.FormResize }




procedure TForm_Console.FormShow(Sender: TObject);
begin
  Form_Console.Left := F1_x;
  Form_Console.Top := F1_y;
  Form_Console.Height := F1_Height;



end; { procedure TForm_Console.FormShow }



procedure TForm_Console.TerminalKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

  if Shift = [] then
    case Key of
      27 : Form_Console.Close; // ESC
  end; { if Shift = [] then }

end; { procedure TForm_Console.TerminalKeyDown }





procedure TForm_Console.Timer1Timer(Sender: TObject);
begin

  if DISK_MONITOR_Counter>0 then begin

    DEC(DISK_MONITOR_Counter);

    if DISK_MONITOR_Counter=0 then begin

      DISK_MONITOR_OFF;

    end; { if DISK_MONITOR_Counter=0 then }

  end; { if DISK_MONITOR_Counter>0 then }

end; { procedure TForm_Console.Timer1Timer }









{ ***** Listbox_Meldungen ***** }


procedure TForm_Console.ListBox_Messages_Clear;
var
  FC_counter : Integer;

begin

  for FC_counter:=0 to Length_Color_List do begin
    Color_List[FC_counter]:=ClBlack;
  end;

  ListBox_Messages.Clear;

end; { procedure TForm_Console.ListBox_Messages_Clear }





procedure TForm_Console.ListBox_Messages_Add_Item_Color(AI_Text : String;
                                  AI_Color : TColor);
var
  AI_Index : Integer;

begin

  ListBox_Messages.Items.Add(AI_Text);
  AI_Index:=ListBox_Messages.Count-1;

  if AI_Index<Length_Color_List then
    Color_List[AI_Index]:=AI_Color
  else
    Color_List[0]:=AI_Color;

  // Immer den zuletzt hinzugefuegten Eintrag visible_flag machen.
  // Plattformneutrale LCL-Loesung (Windows + Linux), ersetzt das
  // urspruengliche Windows-only SendMessage(..., LB_SETTOPINDEX, ...):
  if ListBox_Messages.Items.Count > 0 then
    ListBox_Messages.TopIndex := ListBox_Messages.Items.Count - 1;

end; { procedure TForm_Console.ListBox_Messages_Add_Item_Color }







procedure TForm_Console.ListBox_MessagesDrawItem(Control: TWinControl;
  Index: Integer; ARect: TRect; State: TOwnerDrawState);
var
  VG_Color : TColor;
begin

  with (Control as TListbox) do begin

    if Index<Length_Color_List then begin

      VG_Color:=Color_List[Index];
      Canvas.Font.Color:=VG_Color;

      Canvas.FillRect(ARect); // Hintergrund malen
      Canvas.TextOut(ARect.Left, ARect.Top, Items[Index]); // Text ausgeben

    end; { if Index<Length_Color_List then }

  end; { with (Control as TListbox) do }

end; { procedure TForm_Console.ListBox_MessagesDrawItem }

procedure TForm_Console.RadioGroup1Click(Sender: TObject);
begin

end;



// *** Laufwerke ***











// *** Buttons unten ***




procedure TForm_Console.Button_LOG_Messages_ClearClick(Sender: TObject);
begin
  ListBox_Messages_Clear;
end; { procedure TForm_Console.Button_LOG_Messages_ClearClick }




procedure TForm_Console.Button_LOG_Messages_SaveClick(Sender: TObject);
begin
    ListBox_Messages.Items.SaveToFile(Program_File_Path+PRINT_File_Folder+path_separator+'LOG_Meldungen.txt');
end; { procedure TForm_Console.Button_LOG_Messages_SaveClick }

procedure TForm_Console.Button_Save_DrivesClick(Sender: TObject);
begin

end;





procedure TForm_Console.Button_CloseClick(Sender: TObject);
begin
  Close;
end; { procedure TForm_Console.ButtonCloseClick }




function TForm_Console.txtf(txt_nr : Word) : String;
begin
  Result:=lang_text(unit_MainUnit_frm,txt_nr);
end; { txtf }


function TForm_Console.txtp(txt_nr : Word) : String;
begin
  Result:=lang_text(unit_MainUnit_pas,txt_nr);
end; { txtp }





procedure TForm_Console.FormDestroy(Sender: TObject);
begin

  if PortConnected then
    LazSerial1.Close;

  if wdos_Drive.Allow_Save then
    wdos_Drive.Save_Drives;

  if Assigned(FIni) then begin

    FIni.WriteInteger('FORM','F1_x', Form_Console.Left );
    FIni.WriteInteger('FORM','F1_y', Form_Console.Top );
    FIni.WriteInteger('FORM','F1_Height', Form_Console.Height );

    FIni.WriteInteger('FORM','F2_x', Form_CONS.Left );
    FIni.WriteInteger('FORM','F2_y', Form_CONS.Top );

    FIni.WriteBool('FORM','LOG_CONIN', LOG_CONIN );
    FIni.WriteBool('FORM','LOG_CONOUT', LOG_CONOUT );
    FIni.WriteBool('FORM','LOG_READ', LOG_READ );
    FIni.WriteBool('FORM','LOG_WRITE', LOG_WRITE );
    FIni.WriteBool('FORM','LOG_DEBUG', LOG_DEBUG );

    FIni.WriteBool('FORM','LOG_Term', CheckBox_LOG_TERM.Checked );
    FIni.WriteBool('FORM','send_XOFF', CheckBox_XOFF.Checked );


    { reinen Portnamen speichern (ohne " = Klartextname"), damit der Port beim
      naechsten Start korrekt wiedergefunden wird }
    if (ComboBoxPort.ItemIndex >= 0) and
       (ComboBoxPort.ItemIndex < COM_Port_Array_Index) then
      FIni.WriteString('ComPort', 'ComPort',
                       COM_Port_Array[ComboBoxPort.ItemIndex].Port_Name );
    FIni.WriteInteger('ComPort','BaudRate', ComboBoxBauds.itemindex );


    FIni.WriteInteger('CONOUT', 'Index_FontSize', ComboBox_FontSize.ItemIndex );
    FIni.WriteString('CONOUT', 'DEVICE_VECTOR', IntToBin(DEVICE_VECTOR_Byte,8) );
    FIni.WriteString('CONOUT', 'FONT_NAME', GV_Font_Name );

    FIni.WriteString('PRINT', 'File_Name', PRINT_File_Name );
    FIni.WriteString('PRINT', 'File_Ordner', PRINT_File_Folder );

    case lang_var of

      lang_de : FIni.WriteInteger('CONSOLE64', 'LANGUAGE', 0);
      lang_en : FIni.WriteInteger('CONSOLE64', 'LANGUAGE', 1);

      else
        FIni.WriteInteger('CONSOLE64', 'LANGUAGE', 0);
      end;


    FIni.UpdateFile;
    FIni.Free;
  end; { if Assigned(FIni) then }


 // BOOT_File.Free;


  // Serial-Port schliessen, falls noch offen
  if LazSerial1.Active then
    LazSerial1.Close;



  if PRINT_File.Size>0 then
    PRINT_File.SaveToFile(Program_File_Path+PRINT_File_Folder+path_separator+PRINT_File_Name);

  PRINT_File.Free;

  wdos_Drive.Free;

end; { procedure TForm_Console.FormDestroy }







initialization
  {$I MainUnit.lrs}

end.

