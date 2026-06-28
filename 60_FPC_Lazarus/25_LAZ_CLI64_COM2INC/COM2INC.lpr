program COM2INC;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp
  { you can add units after this };

type

  { TMyApplication }

  TMyApplication = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  end;

{ TMyApplication }

procedure TMyApplication.DoRun;
var
  ErrorMsg: String;
  COM_File : TMemoryStream;
  INC_File, INC2_File : TStringList;
  FileName, Zeile, Adresse : String;
  FileSize, x1, x2 :Integer;
  XByte : Byte;
  Length_Name, Array_Name, CLEAR_String : String;
  Option_CLEAR : Boolean;

begin
  // quick check parameters
  ErrorMsg:=CheckOptions('h','help');
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  // parse parameters
  if HasOption('h','help') then begin
    WriteHelp;
    Terminate;
    Exit;
  end;

  { add your program here }

  writeln('COM2INC (c) by Ronald Daleske');

  Option_CLEAR:=false;


  // COM2INC.exe CPD5.COM CPD5.INC Laenge_BIOS_Array BIOS_ARR CLEAR



  COM_File := TMemoryStream.Create;
  FileName := ParamStr(1);
  Length_Name := ParamStr(3);
  Array_Name := ParamStr(4);
  CLEAR_String := ParamStr(5);



                 {
  FileName := 'CPD5.COM';
  Length_Name := 'Laenge_BIOS_Array';
  Array_Name := 'BIOS_ARR';
  CLEAR_String := 'CLEAR';
                 }



  writeln('COM_File: '+FileName);

  if CLEAR_String='CLEAR' then begin
    Option_CLEAR:=true;
    writeln('CLEAR aktiv');
  end;

  if CLEAR_String='clear' then begin
    Option_CLEAR:=true;
    writeln('clear aktiv');
  end;





  if FileExists(FileName) then begin

    COM_File.LoadFromFile(FileName);

    // wenn CLEAR aktiv ist
    if Option_CLEAR then begin

      while Option_CLEAR do begin

        FileSize:=COM_File.Size;
        COM_File.Position:=FileSize-1;

        COM_File.Read(XByte,1);

        if XByte=0 then
          COM_File.Size:=COM_File.Size-1
        else
          Option_CLEAR:=false;

      end; // while Option_CLEAR do

    end; // if Option_CLEAR then


    INC_File := TStringList.Create;

    FileSize:=COM_File.Size;
    COM_File.Position:=0;
    Adresse:=IntToHex(COM_File.Position,4)+'H';

    Zeile:='  ';

    x2:=1;

    for x1:=0 to FileSize-1 do begin
      COM_File.Read(XByte,1);

      if x1=FileSize-1 then
        Zeile:=Zeile+'$'+IntToHex(XByte,2)
      else
        Zeile:=Zeile+'$'+IntToHex(XByte,2)+',';

      if x2=16 then begin
        Zeile:=Zeile+'	// '+Adresse;
        INC_File.Add(Zeile);
        Adresse:=IntToHex(COM_File.Position,4)+'H';
        Zeile:='  ';
        x2:=0;
      end;

      inc(x2);

    end; { for x1:=0 to FileSize-1 do }

    if Length(Zeile)>2 then begin
      Zeile:=Zeile+'	// '+Adresse;
      INC_File.Add(Zeile);
    end;

    Adresse:=IntToHex(COM_File.Position-1,4);

    INC2_File := TStringList.Create;

    Zeile:='  '+Length_Name+' = $'+Adresse+';';
    INC2_File.Add(Zeile);
    INC2_File.Add(' ');
    Zeile:='  '+Array_Name+' : array[0..'+Length_Name+'] of Byte = (';
    INC2_File.Add(Zeile);
    INC2_File.Add(' ');

    for x1:=0 to INC_File.Count-1 do begin
      Zeile:=INC_File[x1];
      INC2_File.Add(Zeile);
    end;

    INC2_File.Add(' ');
    Zeile:='  );';
    INC2_File.Add(Zeile);

    INC_File.Free;

    FileName := ParamStr(2);

    if Length(FileName)=0 then
      FileName := 'DUMMY.INC';

    writeln('INC_File: '+FileName);
    INC2_File.SaveToFile(FileName);
    INC2_File.Free;

  end
  else begin
    writeln('COM_File: '+FileName+' not found');
    writeln('USAGE: COM2INC <COM_File> <INC_File> <Length_Name> <Array_Name> <CLEAR>');
  end;



  COM_File.Free;


  // stop program loop
  Terminate;
end;


constructor TMyApplication.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;

end;


destructor TMyApplication.Destroy;
begin
  inherited Destroy;
end;


procedure TMyApplication.WriteHelp;
begin
  { add your help code here }
  writeln('Usage: ',ExeName,' -h');
end;

var
  Application: TMyApplication;

{$R *.res}

begin
  Application:=TMyApplication.Create(nil);
  Application.Run;
  Application.Free;
end.

