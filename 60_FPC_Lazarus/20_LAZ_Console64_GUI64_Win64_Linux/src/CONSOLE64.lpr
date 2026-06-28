program CONSOLE64;

{$mode objfpc}{$H+}


uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, LazSerialPort,
  Language_U, MainUnit, Unit_CONS, windos;

// {$IFDEF WINDOWS}{$R CONSOLE.rc}{$ENDIF}

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm_Console, Form_Console);
  Application.CreateForm(TForm_CONS, Form_CONS);
  Application.Run;
end.

