unit Unit_CONS;

{$mode objfpc}{$H+}

interface


uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics,
  Dialogs, fpttf,
  ExtCtrls, StdCtrls, Types, Language_U;




const
  max_Rows = 24;
  max_Columns = 79;

//  Fill_Character = $2E; // '.';
  Fill_Character = $20; // ' '
  Fill_Attribute = $07;

  Folder_WAV = 'WAV';

  // 01..99 -> SEND 2 PARAM
  // Funktionen, die 2 Parameter an das VIDEO-Terminal senden
  VIDEO_SET_CURSOR_POS    = 01;

  VIDEO_Set_Video_Mode    = 02;

  VIDEO_PAR_Scroll_01     = 03;
  VIDEO_PAR_Scroll_02     = 04;
  VIDEO_PAR_Scroll_Up     = 05;

  VIDEO_CONOUT            = 06;

  VIDEO_PAR_Scroll_Down   = 08;

  VIDEO_CONOUT_09H_01     = 10;
  VIDEO_CONOUT_09H_02     = 11;

  VIDEO_CONOUT_0AH_01     = 12;
  VIDEO_CONOUT_0AH_02     = 14;


  // 101..199 -> RECEIVE 2 PARAM
  // Funktionen, die 2 Parameter vom VIDEO-Terminal empfangen
  VIDEO_GET_CURSOR_POS    = 101;
  VIDEO_GET_ChrAtt_CurPos = 102;



  {$I Codepage437.INC}



CONST
  MOUSE_OUT = 60000;



type


  TCharAttr = record
                     Character, Attribute : Byte;
                   end;

  TCharMatrix = Array [0..max_Rows,0..max_Columns] of TCharAttr;



  TMCursor = record
               on_off : Boolean;
               Column, Row : Byte;
               CharAttr : TCharAttr;
             end;


  TScrollVector = record
                     Number_Of_Lines,
                     Blank_Line_Attribute,
                     Top_Left_Column,
                     Top_Left_Row,
                     Bottom_Right_Column,
                     Bottom_Right_Row : Byte;
                   end;


  TMouse = record
             Button : Byte;
             X, Y : Word;
             X_OLD, Y_OLD : Word;
             visible : Boolean;
           end;




  { TForm_CONS }

  TForm_CONS = class(TForm)
    Image_Graf_Mon2: TImage;
    Image_Graf_Mon1: TImage;
    Timer_CURSOR: TTimer;
    Timer_BWS: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormShow(Sender: TObject);
    procedure Image_Graf_Mon1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image_Graf_Mon1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Image_Graf_Mon1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image_Graf_Mon2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image_Graf_Mon2MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Image_Graf_Mon2MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Timer_CURSORTimer(Sender: TObject);
    procedure Timer_BWSTimer(Sender: TObject);




  private
    { private declarations }
    beim_ersten_mal : Boolean;
    BS_Fill_Character,
    PAR_BS_Character  : TCharAttr;

    Vector_Scroll : TScrollVector;

    CONOUT_Line : String;
    CONTROL_ACTIVE : Boolean;

    CharWidth, CharHeight, LeftMargin, TopMargin : Integer;

    procedure Matrix_to_GrafMon;
    function Att2FCol(ATT_Byte : Byte) : TColor;
    function Att2BCol(ATT_Byte : Byte) : TColor;
    function Color4Bit_to_TColor(Byte_4Bit : Byte) : TColor;
    procedure write_key(write_key_value : Word);
    procedure XY(X, Y: Integer);
    function txt(txt_nr : Word) : String;

  public
    { public declarations }

    RMouse : TMouse;

    CharMatrix : TCharMatrix;

    // Puffer fuer die Tasten-Bytes
    KeyBuffer : Array [0..32] of Word;

    MAIN_ComboBox_FontSize_Index : Integer;
    MCursor : TMCursor;


    procedure CLEAR_MATRIX;

    procedure Save_Screen;
    procedure clear_KeyBuffer;
    procedure redraw_Form;

    procedure Video_Send_Routine(DB_Routine, DB_Param1, DB_Param2 : Byte);

    function READ_CHARACTER_AND_ATTRIBUTE_AT_CURSOR_POSITION : TCharAttr;

    procedure Timer_CURSOR_Enabled_true;
    procedure Timer_CURSOR_Enabled_false;

    // Tastatur-Routinen
    function read_key : Word;
    function read_key_stat : Byte;

  end;

var
  Form_CONS: TForm_CONS;

implementation

uses
  MainUnit;


{ TForm_CONS }




procedure TForm_CONS.FormCreate(Sender: TObject);
begin


  BS_Fill_Character.Character:=Fill_Character;
  BS_Fill_Character.Attribute:=Fill_Attribute;

  beim_ersten_mal:=true;

  set_Focus_on_CONOUT:=true;


  // Uebernahme des Font Namen
  Image_Graf_Mon1.Canvas.Font.Name:=GV_Font_Name;
  Image_Graf_Mon2.Canvas.Font.Name:=GV_Font_Name;



  Image_Graf_Mon1.Canvas.Brush.Color:=clWhite;
  Image_Graf_Mon1.Canvas.Pen.Color:=clWhite;
  Image_Graf_Mon1.Canvas.Pen.Width:=1;


  Image_Graf_Mon2.Canvas.Brush.Color:=clWhite;
  Image_Graf_Mon2.Canvas.Pen.Color:=clWhite;
  Image_Graf_Mon2.Canvas.Pen.Width:=1;



  Image_Graf_Mon1.Visible:=true;
  Image_Graf_Mon2.Visible:=false;


  CLEAR_MATRIX;

  CONOUT_Line:='';
  CONTROL_ACTIVE:=false;

  clear_KeyBuffer;

  MAIN_ComboBox_FontSize_Index:=0;

  redraw_Form;

  Form_CONS.KeyPreview:=true;

  RMouse.Button:=0;
  RMouse.X:=0;
  RMouse.Y:=0;
  RMouse.visible:=false;
  RMouse.X_OLD:=MOUSE_OUT;
  RMouse.Y_OLD:=MOUSE_OUT;

end; { procedure TForm_CONS.FormCreate }





function TForm_CONS.Color4Bit_to_TColor(Byte_4Bit : Byte) : TColor;
var
  Result_TColor : TColor;


begin
  {
  value  color
    0    Black
    1    Blue
    2    Green
    3    Cyan
    4    Red
    5    Magenta
    6    Brown
    7    White
    8    Grey
    9    Light Blue
   10    Light Green
   11    Light Cyan
   12    Light Red
   13    Light Magenta
   14    Yellow
   15    High-intensity white
  }

  case Byte_4Bit of

    //                           $bbggrr
    00 : Result_TColor:=TColor($000000); // Schwarz
    01 : Result_TColor:=TColor($AA0000); // Blau
    02 : Result_TColor:=TColor($00AA00); // Gruen
    03 : Result_TColor:=TColor($AAAA00); // Cyan
    04 : Result_TColor:=TColor($0000AA); // Rot
    05 : Result_TColor:=TColor($AA00AA); // Violett
    06 : Result_TColor:=TColor($0055AA); // Braun
    07 : Result_TColor:=TColor($CCCCCC); // Grau
    08 : Result_TColor:=TColor($555555); // Dunkelgrau
    09 : Result_TColor:=TColor($FF5555); // Hellblau
    10 : Result_TColor:=TColor($55FF55); // Hellgruen
    11 : Result_TColor:=TColor($FFFF55); // Hellcyan
    12 : Result_TColor:=TColor($5555FF); // Hellrot
    13 : Result_TColor:=TColor($FF55FF); // Purpur
    14 : Result_TColor:=TColor($55FFFF); // Gelb
    15 : Result_TColor:=TColor($FFFFFF); // Weiss

  else

    Result_TColor:=clBlack;

  end;

  Result:=Result_TColor;

end; { function TForm_CONS.Color4Bit_to_TColor }




function TForm_CONS.Att2FCol(ATT_Byte : Byte) : TColor;
var
  ATT_Color : TColor;
  Attribut_Byte : Byte;
begin

  // Attribute
  //    x x x x          x x x x
  // Hintergrundfarbe Vorgrundfarbe
  Attribut_Byte:=ATT_Byte and $0F;
  ATT_Color:=Color4Bit_to_TColor(Attribut_Byte);

  Result:=ATT_Color;

end; { function TForm_CONS.Att2FCol }





function TForm_CONS.Att2BCol(ATT_Byte : Byte) : TColor;
var
  ATT_Color : TColor;
  Attribut_Byte : Byte;
begin

  // Attribute
  //    x x x x          x x x x
  // Hintergrundfarbe Vorgrundfarbe
  Attribut_Byte:=ATT_Byte and $0F0;
  Attribut_Byte:=Attribut_Byte SHR 4;
  ATT_Color:=Color4Bit_to_TColor(Attribut_Byte);

  Result:=ATT_Color;

end; { function TForm_CONS.Att2BCol }




procedure TForm_CONS.redraw_Form;
begin

  Image_Graf_Mon1.Canvas.Font.Name:=GV_Font_Name;
  Image_Graf_Mon2.Canvas.Font.Name:=GV_Font_Name;

  Form_Console.ComboBox_FontSize_query;

  Image_Graf_Mon1.Canvas.Font.Size:=CONS_FontSize;
  Image_Graf_Mon2.Canvas.Font.Size:=CONS_FontSize;

  Image_Graf_Mon1.Canvas.Font.Color:=Att2FCol(Fill_Attribute);
  Image_Graf_Mon2.Canvas.Font.Color:=Att2FCol(Fill_Attribute);

  Image_Graf_Mon1.Canvas.Brush.Color:=Att2BCol(Fill_Attribute);
  Image_Graf_Mon2.Canvas.Brush.Color:=Att2BCol(Fill_Attribute);

  CharWidth:=Image_Graf_Mon1.Canvas.TextWidth('Z');

  CharHeight:=Image_Graf_Mon1.Canvas.TextHeight('Z');

  Form_CONS.Width:=CharWidth*(max_Columns+1)+20;
  Form_CONS.Height:=CharHeight*(max_Rows+1)+20;


  with Image_Graf_Mon1.Picture.Bitmap do begin
    Width:=Form_CONS.Width-4;
    Height:=Form_CONS.Height-4;
  end;

  with Image_Graf_Mon2.Picture.Bitmap do begin
    Width:=Form_CONS.Width-4;
    Height:=Form_CONS.Height-4;
  end;

  Image_Graf_Mon1.Left:=2;
  Image_Graf_Mon1.Top:=2;

  Image_Graf_Mon2.Left:=2;
  Image_Graf_Mon2.Top:=2;


  LeftMargin := 10;
  TopMargin := 10;

  Image_Graf_Mon1.Canvas.Rectangle(0,0,Image_Graf_Mon1.Width,Image_Graf_Mon1.Height);
  Image_Graf_Mon2.Canvas.Rectangle(0,0,Image_Graf_Mon1.Width,Image_Graf_Mon1.Height);

  Matrix_to_GrafMon;

end; { procedure TForm_CONS.redraw_Form }






// **********************************************************
//
// ****   VIDEO   ****
//
// **********************************************************





procedure TForm_CONS.Matrix_to_GrafMon;
var
  z1, s1, x1, y1 : Integer;
  BS_Character : TCharAttr;


  procedure CharOut(var Image_Graf_Mon : TImage;
                        ZO_x,ZO_y : Integer;
                        ZO_CharAttr : TCharAttr);
  var
    ZO_Word : Word;
    ZO_Text : String;
  begin

    case ZO_CharAttr.Character of

      $00..$1F : ZO_Word := Codepage437a[ZO_CharAttr.Character];

      $80..$FF : ZO_Word := Codepage437b[ZO_CharAttr.Character-$80];

    else
      ZO_Word:=Word(ZO_CharAttr.Character);
    end;

    ZO_Text:=WideChar(ZO_Word);

    Image_Graf_Mon.Canvas.TextOut(ZO_x,ZO_y,ZO_Text);


  end; //  procedure CharOut






begin


  if Image_Graf_Mon1.Visible then begin
    Image_Graf_Mon2.Canvas.Rectangle(0,0,Image_Graf_Mon1.Width,Image_Graf_Mon1.Height);
  end
  else begin
    Image_Graf_Mon1.Canvas.Rectangle(0,0,Image_Graf_Mon1.Width,Image_Graf_Mon1.Height);
  end;


  x1:=LeftMargin;
  y1:=TopMargin;
  for z1:=0 to max_Rows do begin
    for s1:=0 to max_Columns do begin
      BS_Character := CharMatrix[z1,s1];
      x1:=LeftMargin+(CharWidth*s1);
      y1:=TopMargin+(CharHeight*z1);
      if Image_Graf_Mon1.Visible then begin

        Image_Graf_Mon2.Canvas.Brush.Color:=Att2BCol(BS_Character.Attribute);
        Image_Graf_Mon2.Canvas.Rectangle(x1,y1,x1+CharWidth,y1+CharHeight);

        Image_Graf_Mon2.Canvas.Font.Color:=Att2FCol(BS_Character.Attribute);
        CharOut(Image_Graf_Mon2,x1,y1,BS_Character);

      end
      else begin

        Image_Graf_Mon1.Canvas.Brush.Color:=Att2BCol(BS_Character.Attribute);
        Image_Graf_Mon1.Canvas.Rectangle(x1,y1,x1+CharWidth,y1+CharHeight);

        Image_Graf_Mon1.Canvas.Font.Color:=Att2FCol(BS_Character.Attribute);
        CharOut(Image_Graf_Mon1,x1,y1,BS_Character);

      end; { if Image_Graf_Mon1.Visible then }

    end; { for s1:=1 to max_Columns do }

  end; { for z1:=1 to max_Rows do }

  if Image_Graf_Mon1.Visible then begin
    Image_Graf_Mon1.Visible:=false;
    Image_Graf_Mon2.Visible:=true;
  end
  else begin
    Image_Graf_Mon2.Visible:=false;
    Image_Graf_Mon1.Visible:=true;
  end;


end; { procedure TForm_CONS.Matrix_to_GrafMon }









procedure TForm_CONS.Save_Screen;
var
  z1, s1 : Integer;
  Row : String;
  SS_Line : TStringList;
begin
  SS_Line := TStringList.Create;
  for z1:=0 to max_Rows do begin
    Row:='';
    for s1:=0 to max_Columns do begin
      Row:=Row+CHR(CharMatrix[z1,s1].Character);
    end; { for s1:=1 to max_Columns do }
    SS_Line.Add(Row);
  end; { for z1:=1 to max_Rows do }
  SS_Line.SaveToFile(Form_Console.PRINT_File_Folder+path_separator+'LOG_Monitor.txt');
  SS_Line.Free;

end; { procedure TForm_CONS.Save_Screen }





procedure TForm_CONS.CLEAR_MATRIX;
var
  z1, s1 : Integer;
begin

  Timer_CURSOR.Enabled:=false;

  if MCursor.on_off then begin
     CharMatrix[MCursor.Row,MCursor.Column]:=MCursor.CharAttr;
     MCursor.on_off:=false;
  end; { if MCursor.on_off then }

  for s1:=0 to max_Columns do begin
    for z1:=0 to max_Rows do begin
      CharMatrix[z1,s1]:=BS_Fill_Character;
    end;
  end;

  MCursor.Column:=0;
  MCursor.Row:=0;
  MCursor.on_off:=false;

  Timer_CURSOR.Enabled:=true;

end; { procedure TForm_CONS.Reset_Form }






function TForm_CONS.READ_CHARACTER_AND_ATTRIBUTE_AT_CURSOR_POSITION : TCharAttr;
var
  CaA_Character : TCharAttr;
begin

  Timer_CURSOR.Enabled:=false;

  if MCursor.on_off then begin
    CharMatrix[MCursor.Row,MCursor.Column]:=MCursor.CharAttr;
    MCursor.on_off:=false;
  end; { if MCursor.on_off then }

  CaA_Character:=CharMatrix[MCursor.Row,MCursor.Column];

  Timer_CURSOR.Enabled:=true;

  Result:=CaA_Character;

end; { function TForm_CONS.READ_CHARACTER_AND_ATTRIBUTE_AT_CURSOR_POSITION }









{$INCLUDE Video_Send.INC}






{$INCLUDE Keyboard.INC}








procedure TForm_CONS.FormShow(Sender: TObject);
begin

  if beim_ersten_mal then begin
    Form_CONS.Left := Form_Console.F2_x;
    Form_CONS.Top := Form_Console.F2_y;
    beim_ersten_mal:=false;
  end; { if beim_ersten_mal then }


  redraw_Form;


end; { procedure TForm_CONS.FormShow }






procedure TForm_CONS.Timer_CURSORTimer(Sender: TObject);
begin
  Timer_CURSOR.Enabled:=false;

  // Ist der Kursor eingeschaltet (MCursor.on_off:=true;  und "_" wird angezeigt),
  // dann befindet sich auch in MCursor.Character das Character
  if MCursor.on_off then begin
    CharMatrix[MCursor.Row,MCursor.Column]:=MCursor.CharAttr;
    MCursor.on_off:=false;
  end
  else begin
    MCursor.CharAttr:=CharMatrix[MCursor.Row,MCursor.Column];
    CharMatrix[MCursor.Row,MCursor.Column].Character:=Byte('_');
    MCursor.on_off:=true;
  end;

  Timer_CURSOR.Enabled:=true;

end; { procedure TForm_CONS.Timer_CURSORTimer }





procedure TForm_CONS.Timer_BWSTimer(Sender: TObject);
begin
  Timer_BWS.Enabled:=false;

  Matrix_to_GrafMon;

  Timer_BWS.Enabled:=true;
end; { procedure TForm_CONS.Timer_BWSTimer }





procedure TForm_CONS.XY(X, Y: Integer);
var
   MPosX, MPosY : Integer;
   M1_Attr, M2_Attr : Byte;
begin

  
  MPosX:=(X-10)*639 DIV (Image_Graf_Mon1.Width-20);

  if MPosX<0 then
    MPosX:=0;

  if MPosX>639 then
    MPosX:=639;

  RMouse.X:=MPosX DIV 8 * 8;

  MPosY:=(Y-10)*199 DIV (Image_Graf_Mon1.Height-20);

  if MPosY<0 then
    MPosY:=0;

  if MPosY>199 then
    MPosY:=199;

  RMouse.Y:=MPosY DIV 8 * 8;

           {

  if RMouse.visible then begin

    if RMouse.X_OLD<>MOUSE_OUT then begin

      M1_Attr:=CharMatrix[RMouse.Y_OLD div 8,RMouse.X_OLD div 8].Attribute;
      M2_Attr:=M1_Attr shr 4;
      M1_Attr:=M1_Attr shl 4;
      M2_Attr:=M1_Attr+M2_Attr;
      CharMatrix[RMouse.Y_OLD div 8,RMouse.X_OLD div 8].Attribute:=M2_Attr;

    end;

    M1_Attr:=CharMatrix[RMouse.Y div 8,RMouse.X div 8].Attribute;
    M2_Attr:=M1_Attr shr 4;
    M1_Attr:=M1_Attr shl 4;
    M2_Attr:=M1_Attr+M2_Attr;
    CharMatrix[RMouse.Y div 8,RMouse.X div 8].Attribute:=M2_Attr;

    RMouse.X_OLD:=RMouse.X;
    RMouse.Y_OLD:=RMouse.Y;

  end; // if RMouse.visible then

         }
end;




// ***************************************
// ***
// ***    MAUS-Ereignisse
// ***
// ***************************************


// MouseMove 1 und 2

procedure TForm_CONS.Image_Graf_Mon1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);

begin

  XY(X,Y);

end; { procedure TForm_CONS.Image_Graf_Mon1MouseMove }



procedure TForm_CONS.Image_Graf_Mon2MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin

  XY(X,Y);

end; { procedure TForm_CONS.Image_Graf_Mon2MouseMove }




// MouseDown 1 und 2

procedure TForm_CONS.Image_Graf_Mon1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

begin

  XY(X,Y);

  if Button=mbLeft then
    RMouse.Button:=%00000001
  else
    RMouse.Button:=%00000000;

//  Form_CONS.Caption:='X='+IntToStr(X)+' Y='+IntToStr(Y)+'     ';

end; { procedure TForm_CONS.Image_Graf_Mon1MouseDown }



procedure TForm_CONS.Image_Graf_Mon2MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

begin

  XY(X,Y);

  if Button=mbLeft then
    RMouse.Button:=%00000001
  else
    RMouse.Button:=%00000000;

//  Form_CONS.Caption:='X='+IntToStr(X)+' Y='+IntToStr(Y)+'     ';

end; { procedure TForm_CONS.Image_Graf_Mon2MouseDown }




// MouseUp 1 und 2

procedure TForm_CONS.Image_Graf_Mon1MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

  XY(X,Y);

  RMouse.Button:=%00000000;

end; { procedure TForm_CONS.Image_Graf_Mon1MouseUp }




procedure TForm_CONS.Image_Graf_Mon2MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

  XY(X,Y);

  RMouse.Button:=%00000000;

end; { procedure TForm_CONS.Image_Graf_Mon2MouseUp }










procedure TForm_CONS.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

  if Shift = [ssCtrl] then begin
    if MAIN_ComboBox_FontSize_Index>0 then begin
      DEC(MAIN_ComboBox_FontSize_Index);
      Form_Console.ComboBox_FontSize_change;
    end;
  end; { if Shift = [ssCtrl] then }

end; { procedure TForm_CONS.FormMouseWheelDown }



procedure TForm_CONS.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

  if Shift = [ssCtrl] then begin
    if MAIN_ComboBox_FontSize_Index<9 then begin
      INC(MAIN_ComboBox_FontSize_Index);
      Form_Console.ComboBox_FontSize_change;
    end;
  end; { if Shift = [ssCtrl] then }

end; { procedure TForm_CONS.FormMouseWheelUp }





procedure TForm_CONS.Timer_CURSOR_Enabled_true;
begin

  Timer_CURSOR.Enabled:=true;

end; { procedure TForm_CONS.Timer_CURSOR_Enabled_true }



procedure TForm_CONS.Timer_CURSOR_Enabled_false;
begin

  Timer_CURSOR.Enabled:=false;

  if MCursor.on_off then begin
     CharMatrix[MCursor.Row,MCursor.Column]:=MCursor.CharAttr;
     MCursor.on_off:=false;
   end; { if MCursor.on_off then }

end; { procedure TForm_CONS.Timer_CURSOR_Enabled_false }




function TForm_CONS.txt(txt_nr : Word) : String;
begin
  Result:=lang_text(unit_Unit_CONS,txt_nr);
end; { txt }






procedure TForm_CONS.FormDestroy(Sender: TObject);
begin
   //
end; { procedure TForm_CONS.FormDestroy }







initialization
  {$I Unit_CONS.lrs}

end.

