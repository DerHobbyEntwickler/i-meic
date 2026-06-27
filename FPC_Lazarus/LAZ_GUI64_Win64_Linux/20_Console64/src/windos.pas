unit windos;

{$mode objfpc}

interface

uses
  Classes, SysUtils, Language_U;


const
  FDD_path = 'IMAGE_FDD';
  HDD_path = 'IMAGE_HDD';


type

  T_IMAGE_RECORD = record
    File_Name, Description, DISK_Label, OS : String;
    visible_flag, usable, BOOT_DISK : Boolean;
    DISK_IMG : TMemoryStream;
    Size : LongInt;
  end; { T_IMAGE_RECORD = record }



  { Twcpm }

  Twdos = class(TObject)
    constructor Create;
    destructor Destroy; override;
   private
    { private declarations }

    procedure IMAGE_FDD_load;
    procedure IMAGE_HDD_load;
    function txt(txt_nr : Word) : String;

  public
    { public declarations }
   IMAGE_FDD, IMAGE_HDD : T_IMAGE_RECORD;
   Allow_Save : Boolean;
   procedure  Save_Drives;
  end;


  var
    wdos_Drive : Twdos;



implementation

uses
  MainUnit;


constructor Twdos.Create;
begin
  inherited Create;

 // Allow_Save:=true;

  Allow_Save:=false;


  If DirectoryExists(FDD_path) then begin
    IMAGE_FDD_load;
  end
  else begin

    If CreateDir(FDD_path) Then
      Form_Console.ListBox_Messages_Add_Item_Color(txt(001)+FDD_path+
                                                   txt(002),cl_dark_red)
    else
      Form_Console.ListBox_Messages_Add_Item_Color(txt(001)+FDD_path+
                                                   txt(003),cl_dark_red);

  end;



  If DirectoryExists(HDD_path) then begin
    IMAGE_HDD_load;
  end
  else begin

    If CreateDir(HDD_path) Then
      Form_Console.ListBox_Messages_Add_Item_Color(txt(004)+FDD_path+
                                                   txt(002),cl_dark_red)
    else
      Form_Console.ListBox_Messages_Add_Item_Color(txt(004)+FDD_path+
                                                   txt(003),cl_dark_red);

  end;



end; { constructor  Twdos.Create }









procedure Twdos.IMAGE_FDD_load;
var
  DIR_List : TStringList;
  DIR_List_Counter : Integer;


  procedure FDD_DRIVE_to_DIR_List;
  { Liest alle Einträge des Windows-Verzeichnisses DRIVE in die
    StringListe DIR_List ein.
  }
  var
    Info : TSearchRec;
    Count : Longint;
    FileName : String;
  begin
    DIR_List.Clear;

    Count:=0;

    // faAnyFile

    If FindFirst(FDD_path+path_separator+'*.IMG',faNormal,Info)=0 then
      begin
      Repeat
        Inc(Count);
        With Info do begin
            if (Info.Name<>'.') and (Info.Name<>'..') then begin
              // Dateinamen werden in DOS immer gross geschrieben
              FileName := UpperCase(Info.Name);
              DIR_List.Add(FileName);
            end; { if (Info.Name<>'.') and (Info.Name<>'..') then }
        end; { With Info do }
      Until FindNext(info)<>0;
      end;
    FindClose(Info);

 //   DIR_List.SaveToFile('FDD_DIR_List.txt');

  end; { procedure FDD_DRIVE_to_DIR_List }



  procedure FDD_Image_File_check;
  begin

    if FileExists(FDD_path+path_separator+IMAGE_FDD.File_Name) then begin
      IMAGE_FDD.DISK_IMG.LoadFromFile(FDD_path+path_separator+IMAGE_FDD.File_Name);
      IMAGE_FDD.usable:=true;
      IMAGE_FDD.visible_flag:=true;
      Form_Console.Label_FDD.Caption:='Image: '+IMAGE_FDD.File_Name;
      Form_Console.ListBox_Messages_Add_Item_Color(
                             txt(005)+IMAGE_FDD.File_Name+txt(006),cl_dark_green);

    end
    else begin
      IMAGE_FDD.visible_flag:=false;
      IMAGE_FDD.usable:=false;
      Form_Console.Label_FDD.Caption:=txt(007);
      Form_Console.ListBox_Messages_Add_Item_Color(
                             txt(008)+IMAGE_FDD.File_Name+txt(009),cl_dark_red);

    end; // if FileExists(


  end; // procedure FDD_Image_File_check



begin

  DIR_List:=TStringList.Create;

  FDD_DRIVE_to_DIR_List;

  // Grundeinstellungen fuer IMAGE_FDD
  IMAGE_FDD.Description:='';
  IMAGE_FDD.DISK_Label:='';
  IMAGE_FDD.OS:='';

  IMAGE_FDD.BOOT_DISK:=false;
  IMAGE_FDD.Size:=0;

  IMAGE_FDD.DISK_IMG:=TMemoryStream.Create;

  IMAGE_FDD.usable:=false;

  for DIR_List_Counter:=0 to DIR_List.Count-1 do begin

    if IMAGE_FDD.usable=false then begin

      IMAGE_FDD.File_Name:=DIR_List[DIR_List_Counter];
      FDD_Image_File_check;

    end; // if IMAGE_FDD.usable=false then

  end; // for DIR_List_Counter:=0 to DIR_List.Count-1 do

  DIR_List.Free;

end; { procedure Twdos.IMAGE_FDD_load }










procedure Twdos.IMAGE_HDD_load;
var
  DIR_List : TStringList;
  DIR_List_Counter : Integer;


  procedure HDD_DRIVE_to_DIR_List;
  { Liest alle Einträge des Verzeichnisses HDD_path in die
    StringListe DIR_List ein.
  }
  var
    Info : TSearchRec;
    Count : Longint;
    FileName : String;
  begin
    DIR_List.Clear;

    Count:=0;

    // faAnyFile

    If FindFirst(HDD_path+path_separator+'*.IMG',faNormal,Info)=0 then
      begin
      Repeat
        Inc(Count);
        With Info do begin
            if (Info.Name<>'.') and (Info.Name<>'..') then begin
              // Dateinamen werden in DOS immer gross geschrieben
              FileName := UpperCase(Info.Name);
              DIR_List.Add(FileName);
            end; { if (Info.Name<>'.') and (Info.Name<>'..') then }
        end; { With Info do }
      Until FindNext(info)<>0;
      end;
    FindClose(Info);

 //   DIR_List.SaveToFile('HFDD_DIR_List.txt');

  end; { procedure FDD_DRIVE_to_DIR_List }



  procedure HDD_Image_File_check;
  begin

    if FileExists(HDD_path+path_separator+IMAGE_HDD.File_Name) then begin
      IMAGE_HDD.DISK_IMG.LoadFromFile(HDD_path+path_separator+IMAGE_HDD.File_Name);
      IMAGE_HDD.usable:=true;
      IMAGE_HDD.visible_flag:=true;
      Form_Console.Label_HDD.Caption:='Image: '+IMAGE_HDD.File_Name;
      Form_Console.ListBox_Messages_Add_Item_Color(
                          txt(005)+IMAGE_HDD.File_Name+txt(006),cl_dark_green);
    end
    else begin
      IMAGE_HDD.visible_flag:=false;
      IMAGE_HDD.usable:=false;
      Form_Console.Label_HDD.Caption:=txt(007);
      Form_Console.ListBox_Messages_Add_Item_Color(
                          txt(008)+IMAGE_HDD.File_Name+txt(009),cl_dark_red);
    end; // if FileExists(


  end; // procedure HDD_Image_File_check



begin

  DIR_List:=TStringList.Create;

  HDD_DRIVE_to_DIR_List;

  // Grundeinstellungen fuer IMAGE_HDD
  IMAGE_HDD.Description:='';
  IMAGE_HDD.DISK_Label:='';
  IMAGE_HDD.OS:='';

  IMAGE_HDD.BOOT_DISK:=false;
  IMAGE_HDD.Size:=0;

  IMAGE_HDD.DISK_IMG:=TMemoryStream.Create;

  IMAGE_HDD.usable:=false;

  for DIR_List_Counter:=0 to DIR_List.Count-1 do begin

    if IMAGE_HDD.usable=false then begin

      IMAGE_HDD.File_Name:=DIR_List[DIR_List_Counter];
      HDD_Image_File_check;

    end; // if IMAGE_HFDD.usable=false then

  end; // for DIR_List_Counter:=0 to DIR_List.Count-1 do

  DIR_List.Free;

end; { procedure Twdos.IMAGE_HDD_load }






procedure  Twdos.Save_Drives;

begin

  IMAGE_HDD.DISK_IMG.SaveToFile(HDD_path+path_separator+IMAGE_HDD.File_Name);
  IMAGE_FDD.DISK_IMG.SaveToFile(FDD_path+path_separator+IMAGE_FDD.File_Name);

end; { constructor  Twdos.Save_Drives }



function Twdos.txt(txt_nr : Word) : String;
begin
  Result:=lang_text(unit_windos,txt_nr);
end; { txt }



destructor Twdos.Destroy;
begin

  inherited Destroy;
end; { destructor Twdos.Destroy }






end.

