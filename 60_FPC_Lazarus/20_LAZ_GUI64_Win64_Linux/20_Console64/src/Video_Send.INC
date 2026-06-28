

procedure TForm_CONS.Video_Send_Routine(DB_Routine, DB_Param1, DB_Param2 : Byte);






  procedure SET_VIDEO_MODE(VM_Byte : Byte);
  begin

    CLEAR_MATRIX;

  end; { procedure TForm_CONS.SET_VIDEO_MODE }






  procedure SET_CURSOR_POSITION(Row, Column : Byte); // bezogen auf 0,0 !!!
  begin

    Timer_CURSOR.Enabled:=false;

    if MCursor.on_off then begin
      CharMatrix[MCursor.Row,MCursor.Column]:=MCursor.CharAttr;
      MCursor.on_off:=false;
    end; { if MCursor.on_off then }


    MCursor.Row:=Row;
    MCursor.Column:=Column;

    if (MCursor.Row>max_Rows) then
      MCursor.Row:=max_Rows;

    if (MCursor.Column>max_Columns) then
      MCursor.Column:=max_Columns;

    MCursor.CharAttr:=CharMatrix[MCursor.Row,MCursor.Column];

    Timer_CURSOR.Enabled:=true;

  end; { procedure SET_CURSOR_POSITION }






  {
  Der Bildschirm wird im 80x25-Modus in 25 Zeilen zu je 80 Spalten aufgeteilt.

      0 1 . . . .  Spalten . . . . . . 79
      -----------------------------------
    0 |   5,3  12 Spalten (14-3+1)      |
  Z 1 |    --------------------         |
  e 2 |    |                  |         |
  i   |    |                  |5 Zeilen |
  l   |    |      Fenster     | (9-5+1) |
  e   |    |                  |         |
  n   |    --------------------         |
      |                      9,14       |
   23 |                                 |
   24 -----------------------------------
                                      24,79

  Bild 2.2: Bildschirmraster im 80x25-Textmodus
  Mit den Werten in den Registern CX, DX werden die beiden Eckpunkte des ausgewählten
  Bildschirmfensters spezifiziert. Die Koordinaten (0,0),(24,79) setzen das Fenster über den
  gesamten Bildschirm. Das AL-Register gibt an, wie viele Zeilen nach oben gescrollt
  werden. Ist der Wert = 0, dann wird das Fenster gelöscht. Der gleiche Effekt tritt auf, wenn
  der Wert in AL der Zeilenzahl innerhalb des Fensters entspricht, da ja von unten Leerzeilen
  eingefügt werden. Mit dem Wert des Registers BH wird das Attribute der Leerzeile
  (blinkend, unterstrichen, invers etc.) festgelegt. Die Kodierung der Attribute wird bei der
  Unterfunktion (AH = 8) vorgestellt.
  }
  procedure VIDEO_Scroll_Up(Vector_Scroll_UP : TScrollVector);
  var
    z1, s1 : Byte;
    BS_Character : TCharAttr;
    Window_Row_Count,
    Window_Row_Counter,
    Line_Counter : Byte;
  begin


    Timer_CURSOR.Enabled:=false;

    if MCursor.on_off then begin
      CharMatrix[MCursor.Row,MCursor.Column]:=MCursor.CharAttr;
      MCursor.on_off:=false;
    end; { if MCursor.on_off then }


    BS_Character.Character:=Fill_Character;
    BS_Character.Attribute:=Vector_Scroll_UP.Blank_Line_Attribute;

    Window_Row_Count:=Vector_Scroll_UP.Bottom_Right_Row-
                           Vector_Scroll_UP.Top_Left_Row+1;

    if Vector_Scroll_UP.Number_Of_Lines=0 then begin

      CLEAR_MATRIX;

    end // if Vector_Scroll_Up.Number_Of_Lines=0 then
    else begin

      for Line_Counter:=1 to Vector_Scroll_UP.Number_Of_Lines do begin

        IF Window_Row_Count>1 THEN BEGIN

          for Window_Row_Counter:=1 to Window_Row_Count do begin

            z1:=Vector_Scroll_UP.Top_Left_Row+Window_Row_Counter-1;
            for s1:=Vector_Scroll_UP.Top_Left_Column to
                    Vector_Scroll_UP.Bottom_Right_Column do begin
               CharMatrix[z1,s1]:=CharMatrix[z1+1,s1];
            end; { for s1:=Vector_Scroll_Up }

          end; { for Window_Row_Counter:=1 }

        end; { IF Window_Row_Count>1 THEN }

        z1:=Vector_Scroll_UP.Bottom_Right_Row;
        for s1:=Vector_Scroll_UP.Top_Left_Column to
                Vector_Scroll_UP.Bottom_Right_Column do begin
           CharMatrix[z1,s1]:=BS_Character;
        end; { for s1:=Vector_Scroll }

      end; { for Line_Counter:=1 }


      //
      Form_Console.ListBox_Messages_Add_Item_Color(
           'Scroll_Up - AnzahlZeilen='+IntToStr(Vector_Scroll_UP.Number_Of_Lines)+
           ' AttributLZ='+IntToHex(Vector_Scroll_UP.Blank_Line_Attribute,2)+'H',cl_dark_blue);

      Form_Console.ListBox_Messages_Add_Item_Color(
           '            EckspalteOL='+IntToStr(Vector_Scroll_UP.Top_Left_Column)+
           ' EckzeileOL='+IntToStr(Vector_Scroll_UP.Top_Left_Row),cl_dark_blue);

      Form_Console.ListBox_Messages_Add_Item_Color(
           '            EckspalteUR='+IntToStr(Vector_Scroll_UP.Bottom_Right_Column)+
           ' EckzeileUR='+IntToStr(Vector_Scroll_UP.Bottom_Right_Row),cl_dark_blue);


    end; // else Vector_Scroll_Up.Number_Of_Lines=0 then


    Timer_CURSOR.Enabled:=true;



  end; { procedure TForm_CONS.VIDEO_Scroll_Up }





  procedure VIDEO_Scroll_Down(Vector_Scroll_Down : TScrollVector);
  var
    z1, s1 : Byte;
    BS_Character : TCharAttr;
    Window_Row_Count,
    Window_Row_Counter,
    Line_Counter : Byte;
  begin


    Timer_CURSOR.Enabled:=false;

    if MCursor.on_off then begin
      CharMatrix[MCursor.Row,MCursor.Column]:=MCursor.CharAttr;
      MCursor.on_off:=false;
    end; { if MCursor.on_off then }


    BS_Character.Character:=Fill_Character;
    BS_Character.Attribute:=Vector_Scroll_Down.Blank_Line_Attribute;

    Window_Row_Count:=Vector_Scroll_Down.Bottom_Right_Row-
                           Vector_Scroll_Down.Top_Left_Row+1;

    if Vector_Scroll_Down.Number_Of_Lines=0 then begin

      CLEAR_MATRIX;

    end // if Vector_Scroll.Number_Of_Lines=0 then
    else begin

      for Line_Counter:=1 to Vector_Scroll_Down.Number_Of_Lines do begin

        IF Window_Row_Count>1 THEN BEGIN

          for Window_Row_Counter:=1 to Window_Row_Count do begin

            z1:=Vector_Scroll_Down.Bottom_Right_Row-Window_Row_Counter+1;
            for s1:=Vector_Scroll_Down.Top_Left_Column to
                    Vector_Scroll_Down.Bottom_Right_Column do begin
               CharMatrix[z1,s1]:=CharMatrix[z1-1,s1];
            end; { for s1:=Vector_Scroll_Up }

          end; { for Window_Row_Counter:=1 }

        end; { IF Window_Row_Count>1 THEN }

        z1:=Vector_Scroll_Down.Top_Left_Row;
        for s1:=Vector_Scroll_Down.Top_Left_Column to
                Vector_Scroll_Down.Bottom_Right_Column do begin
           CharMatrix[z1,s1]:=BS_Character;
        end; { for s1:=Vector_Scroll_Up }

      end; { for Line_Counter:=1 }


      //
      Form_Console.ListBox_Messages_Add_Item_Color(
           'Scroll_Down - AnzahlZeilen='+IntToStr(Vector_Scroll_Down.Number_Of_Lines)+
           ' AttributLZ='+IntToHex(Vector_Scroll_Down.Blank_Line_Attribute,2)+'H',cl_dark_blue);

      Form_Console.ListBox_Messages_Add_Item_Color(
           '            EckspalteOL='+IntToStr(Vector_Scroll_Down.Top_Left_Column)+
           ' EckzeileOL='+IntToStr(Vector_Scroll_Down.Top_Left_Row),cl_dark_blue);

      Form_Console.ListBox_Messages_Add_Item_Color(
           '            EckspalteUR='+IntToStr(Vector_Scroll_Down.Bottom_Right_Column)+
           ' EckzeileUR='+IntToStr(Vector_Scroll_Down.Bottom_Right_Row),cl_dark_blue);


    end; // else Vector_Scroll_Up.Number_Of_Lines=0 then


    Timer_CURSOR.Enabled:=true;


  end; { procedure TForm_CONS.VIDEO_Scroll_Down }






  procedure Scroll_Lines;
  var
    z1, s1 : Byte;
  begin

    for z1:=0 to max_Rows-1 do begin
      for s1:=0 to max_Columns do begin
        CharMatrix[z1,s1]:=CharMatrix[z1+1,s1];
      end;
    end; // for z1:=0 to max_Rows-1 do
    for s1:=0 to max_Columns do begin
      CharMatrix[max_Rows,s1]:=BS_Fill_Character;
    end;

    MCursor.Column:=0;
    MCursor.Row:=max_Rows;

  end; { procedure Scroll_Lines }




  procedure CURSOR_DOWN;
  begin

    Inc(MCursor.Row);
    if MCursor.Row>max_Rows then begin
      Scroll_Lines;
    end; // if MCursor.Row>max_Rows then

  end; { procedure CURSOR_DOWN }






  procedure CURSOR_RIGHT;
  begin

    Inc(MCursor.Column);

    if MCursor.Column>max_Columns then begin
      MCursor.Column:=0;
      CURSOR_DOWN;
    end; { if MCursor.Column>max_Columns then }

  end; { procedure CURSOR_RIGHT }







  procedure VIDEO_TELETYPE(CON_Character : Byte);





    procedure Character_to_Matrix(ZM_Character : Byte);
    begin
      CharMatrix[MCursor.Row,MCursor.Column].Character:=ZM_Character;
      CURSOR_RIGHT;
    end; { procedure Character_to_Matrix }





    procedure Special_Character_to_Matrix;
    var
      S_Line : String;
    begin
      S_Line:='['+IntToHex(CON_Character,2)+']';

      Form_Console.ListBox_Messages_Add_Item_Color('CODE : '+S_Line+
                                                   txt(001),cl_dark_red);

    end; { procedure Special_Character_to_Matrix }




    procedure CURSOR_UP;
    begin
      if MCursor.Row>0 then
        Dec(MCursor.Row);

    end; { procedure CURSOR_UP }




    procedure CURSOR_LEFT;
    begin
      if MCursor.Column>0 then
        Dec(MCursor.Column);

    end; { procedure CURSOR_LEFT }




    procedure CURSOR_HOME;
    begin
      MCursor.Column:=0;
      MCursor.Row:=0;
    end; { procedure CURSOR_HOME }




    procedure DELETE_CHARACTER;
    var
      s1 : Byte;
    begin
      for s1:=MCursor.Column to max_Columns-1 do
        CharMatrix[MCursor.Row,s1]:=CharMatrix[MCursor.Row,s1+1];

    end; { procedure DELETE_CHARACTER }





    procedure RUN_DEL;
    begin

      if MCursor.Column>0 then begin
        dec(MCursor.Column);
        CharMatrix[MCursor.Row,MCursor.Column]:=BS_Fill_Character;
      end;

    end; { procedure RUN_DEL }





    procedure Normal_Terminal_Mode;
    begin

      case CON_Character of
        $01 : CURSOR_HOME;   // auf Pos 0,0
        $04 : CURSOR_RIGHT;  // rechts
        $05 : CURSOR_UP;     // oben
        $08 : RUN_DEL;       // BS
        $09 : MCursor.Column:=8 * (MCursor.Column div 8);  // TAB
        $0A : CURSOR_DOWN; // LF
        $0C : CLEAR_MATRIX; // CLS - Clear Screen
        $0D : MCursor.Column:=0;  // CR
        $13 : CURSOR_LEFT;  // links
        $18 : CURSOR_DOWN; // unten

        $20..$7E : Character_to_Matrix(CON_Character);

        $7F : RUN_DEL;

      else
      //  Special_Character_to_Matrix;
        Character_to_Matrix(CON_Character);
      end;

    end; { procedure Normal_Terminal_Mode }



  begin

    if set_Focus_on_CONOUT then begin
      set_Focus_on_CONOUT:=false;
      Form_CONS.SetFocus;
    end;

    Timer_CURSOR.Enabled:=false;

    if MCursor.on_off then begin
       CharMatrix[MCursor.Row,MCursor.Column]:=MCursor.CharAttr;
       MCursor.on_off:=false;
     end; { if MCursor.on_off then }


    if Form_Console.CheckBox_LOG_TERM.Checked then begin


        case CON_Character of
          $20..$7F : begin
                       if CONTROL_ACTIVE then begin
                         Form_Console.ListBox_Messages_Add_Item_Color(CONOUT_Line,cl_dark_brown);
                         CONOUT_Line:='';
                         CONTROL_ACTIVE:=false;
                       end;
                       CONOUT_Line:=CONOUT_Line+CHR(CON_Character);
                     end;

          $0D : begin
                  Form_Console.ListBox_Messages_Add_Item_Color(CONOUT_Line,cl_dark_brown);
                end; { $0D }

          $0A : begin
                  CONOUT_Line:='';
                end; { $0A }
        else
          CONOUT_Line:=CONOUT_Line+'['+IntToHex(CON_Character,2)+']';
        end;


    end; { if Form_CPD2.CheckBox_LOG_TERM.Checked then }

    Normal_Terminal_Mode;

    Timer_CURSOR.Enabled:=true;

  end; { procedure VIDEO_TELETYPE }





  procedure VIDEO_CON_09H(VC9_Character : TCharAttr; VC9_Length : Word);
  var
    VC9_Counter : Word;
    VCursor : TMCursor;
  begin

    if set_Focus_on_CONOUT then begin
      set_Focus_on_CONOUT:=false;
      Form_CONS.SetFocus;
    end;

    Timer_CURSOR.Enabled:=false;

    if MCursor.on_off then begin
      CharMatrix[MCursor.Row,MCursor.Column]:=MCursor.CharAttr;
      MCursor.on_off:=false;
    end; { if MCursor.on_off then }

    // Character und Attribute an Cursorposition schreiben
    CharMatrix[MCursor.Row,MCursor.Column]:=VC9_Character;

    if VC9_Length>1 then begin

      VCursor:=MCursor;

      for VC9_Counter:=2 to VC9_Length do begin
        CURSOR_RIGHT;
        CharMatrix[MCursor.Row,MCursor.Column]:=VC9_Character;
      end;

      MCursor:=VCursor;

    end; // if VC9_Length>1 then

    Timer_CURSOR.Enabled:=true;

  end; // procedure VIDEO_CON_09H







    procedure VIDEO_CON_0AH(VCA_Character : TCharAttr; VCA_Length : Word);
    var
      VCA_Counter : Word;
      VCursor : TMCursor;
    begin

      if set_Focus_on_CONOUT then begin
        set_Focus_on_CONOUT:=false;
        Form_CONS.SetFocus;
      end;

      Timer_CURSOR.Enabled:=false;

      if MCursor.on_off then begin
        CharMatrix[MCursor.Row,MCursor.Column]:=MCursor.CharAttr;
        MCursor.on_off:=false;
      end; { if MCursor.on_off then }

      // Character und Attribute an Cursorposition schreiben
      CharMatrix[MCursor.Row,MCursor.Column].Character:=VCA_Character.Character;

      if VCA_Length>1 then begin

        VCursor:=MCursor;

        for VCA_Counter:=2 to VCA_Length do begin
          CURSOR_RIGHT;
          CharMatrix[MCursor.Row,MCursor.Column]:=VCA_Character;
        end;

        MCursor:=VCursor;

      end; // if VCA_Length>1 then

      Timer_CURSOR.Enabled:=true;

    end; // procedure VIDEO_CON_0AH





begin

  case DB_Routine of
                           //                  Row P2   Column P1
    VIDEO_SET_CURSOR_POS : SET_CURSOR_POSITION(DB_Param2, DB_Param1);

    VIDEO_Set_Video_Mode : SET_VIDEO_MODE(DB_Param1);

    VIDEO_PAR_Scroll_01  : begin
                             Vector_Scroll.Number_Of_Lines:=DB_Param1;
                             Vector_Scroll.Blank_Line_Attribute:=DB_Param2;
                           end;

    VIDEO_PAR_Scroll_02  : begin
                             Vector_Scroll.Top_Left_Column:=DB_Param1;
                             Vector_Scroll.Top_Left_Row:=DB_Param2;
                           end;

    VIDEO_PAR_Scroll_Up  : begin
                             Vector_Scroll.Bottom_Right_Column:=DB_Param1;
                             Vector_Scroll.Bottom_Right_Row:=DB_Param2;
                             VIDEO_Scroll_Up(Vector_Scroll);
                           end;

    VIDEO_PAR_Scroll_Down: begin
                             Vector_Scroll.Bottom_Right_Column:=DB_Param1;
                             Vector_Scroll.Bottom_Right_Row:=DB_Param2;
                             VIDEO_Scroll_Down(Vector_Scroll);
                           end;

    VIDEO_CONOUT         : begin
                             VIDEO_TELETYPE(DB_Param1);
                           end;

    VIDEO_CONOUT_09H_01  : begin
                             PAR_BS_Character.Character:=DB_Param1;
                             PAR_BS_Character.Attribute:=DB_Param2;
                           end;


    VIDEO_CONOUT_09H_02  : begin
                             VIDEO_CON_09H(PAR_BS_Character,(DB_Param2*256)+DB_Param1);
                           end;


    VIDEO_CONOUT_0AH_01  : begin
                             PAR_BS_Character.Character:=DB_Param1;
                           end;


    VIDEO_CONOUT_0AH_02  : begin
                             VIDEO_CON_0AH(PAR_BS_Character,(DB_Param2*256)+DB_Param1);
                           end;



  else

    Form_Console.ListBox_Messages_Add_Item_Color(txt(002)+
                             IntToHex(DB_Routine,2)+txt(003),cl_dark_red);

  end;

end; { procedure TForm_CONS.Video_Send_Routine }







