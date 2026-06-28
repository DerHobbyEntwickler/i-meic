




// **********************************************************
//
// **** Keyboard ****
//
// **********************************************************





procedure TForm_CONS.clear_KeyBuffer;
var
  key_counter : Integer;
begin
  for key_counter:=0 to 32 do begin
    KeyBuffer[key_counter] := 0;
  end;
end; { procedure TForm_CONS.clear_KeyBuffer }






// CONST
function TForm_CONS.read_key_stat : Byte;
var
  read_key_value : Byte;
  KeyBuffer_Counter : Word;
begin

  KeyBuffer_Counter:=KeyBuffer[0];

  if KeyBuffer_Counter=0 then
    read_key_value:=$00
  else
    read_key_value:=$FF;

  Result:=read_key_value;

end; { function TForm_CONS.read_key_stat }




// CONIN
function TForm_CONS.read_key : Word;
var
  key_counter, w1,
  KeyBuffer_Counter, KeyBuffer_Value : Word;
begin

  KeyBuffer_Value:=0;

  if read_key_stat=$FF then begin

    KeyBuffer_Counter:=KeyBuffer[0];
    KeyBuffer_Value:=KeyBuffer[1];
    dec(KeyBuffer_Counter);
    if KeyBuffer_Counter>0 then begin
      for key_counter:=1 to KeyBuffer_Counter do begin
        w1 := KeyBuffer[key_counter+1];
        KeyBuffer[key_counter] := w1;
      end;
    end;
    KeyBuffer[0]:=KeyBuffer_Counter;

  end;

  Result:=KeyBuffer_Value;

end; { function TForm_CONS.read_key }










procedure TForm_CONS.write_key(write_key_value : Word);
var
  KeyBuffer_Counter : Word;
begin

  KeyBuffer_Counter:=KeyBuffer[0];

  if KeyBuffer_Counter<32 then begin
    inc(KeyBuffer_Counter);
    KeyBuffer[KeyBuffer_Counter]:=write_key_value;
  end;

  KeyBuffer[0]:=KeyBuffer_Counter;

end; { procedure TForm_CONS.write_key }











procedure TForm_CONS.FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
var
  Character : Word;
begin

  Character := $00;

  if Shift = [] then begin

    case Key of
      // Buchstaben a..z
      $41 : Character:=$1E61; // a
      $42 : Character:=$3062; // b
      $43 : Character:=$2E63; // c
      $44 : Character:=$2064; // d
      $45 : Character:=$1265; // e
      $46 : Character:=$2166; // f
      $47 : Character:=$2267; // g
      $48 : Character:=$2368; // h
      $49 : Character:=$1769; // i
      $4A : Character:=$246A; // j
      $4B : Character:=$256B; // k
      $4C : Character:=$266C; // l
      $4D : Character:=$326D; // m
      $4E : Character:=$316E; // n
      $4F : Character:=$186F; // o
      $50 : Character:=$1970; // p
      $51 : Character:=$1071; // q
      $52 : Character:=$1372; // r
      $53 : Character:=$1F73; // s
      $54 : Character:=$1474; // t
      $55 : Character:=$1675; // u
      $56 : Character:=$2F76; // v
      $57 : Character:=$1177; // w
      $58 : Character:=$2D78; // x
      $59 : Character:=$1579; // y
      $5A : Character:=$2C7A; // z


      // Zahlen 1..0
      $31 : Character:=$0231; // 1
      $32 : Character:=$0332; // 2
      $33 : Character:=$0433; // 3
      $34 : Character:=$0534; // 4
      $35 : Character:=$0635; // 5
      $36 : Character:=$0736; // 6
      $37 : Character:=$0837; // 7
      $38 : Character:=$0938; // 8
      $39 : Character:=$0A39; // 9
      $30 : Character:=$0B30; // 0


      // Character 1. Row
      $1B : Character:=$011B; // ESC

      $70 : Character:=$3B00; // F1
      $71 : Character:=$3C00; // F2
      $72 : Character:=$3D00; // F3
      $73 : Character:=$3E00; // F4
      $74 : Character:=$3F00; // F5
      $75 : Character:=$4000; // F6
      $76 : Character:=$4100; // F7
      $77 : Character:=$4200; // F8
      $78 : Character:=$4300; // F9
      $79 : Character:=$4400; // F10
      $7A : Character:=$8500; // F11
      $7B : Character:=$8600; // F12

      // Character 2. Row
      $DB : Character:=$0CE1; // sz
      $08 : Character:=$0E08; // BackSpace

      // Character 3. Row
      $09 : Character:=$0F09; // TAB
      $BA : Character:=$1A81; // Ue
      $BB : Character:=$1B2B; // +

      // Character 4. Row
      $CD : Character:=$2794; // Oe
      $CE : Character:=$2884; // Ae
      $BF : Character:=$2B23; // #
      $0D : Character:=$1C0D; // Enter

      // Character 5. Row
      $E2 : Character:=$563C; // <
      $BC : Character:=$332C; // ,
      $BE : Character:=$342E; // .
      $BD : Character:=$352D; // -

      // Character 6. Row
      $20 : Character:=$3920; // SpaceBar

      // Tastenfeld 6 Tasten
      $2D : Character:=$5200; // einfg
      $24 : Character:=$4700; // pos1
      $21 : Character:=$4900; // bild hoch = PgUp
      $2E : Character:=$5300; // entf
      $23 : Character:=$4F00; // ende
      $22 : Character:=$5100; // bild runter = PgDn

      // Kursortasten
      $25 : Character:=$4B00; // <- Left Arrow
      $28 : Character:=$5000; // v  Down Arrow
      $27 : Character:=$4D00; // -> Right Arrow
      $26 : Character:=$4800; // -> Up Arrow





    else
      Character := $00;
    end;



  end; { if Shift = [] then }


  if Shift = [SSSHIFT] then begin
    if Key<>16 then begin  // Shift-Taste
      case Key of
        // Buchstaben A..Z
        $41 : Character:=$1E41; // A
        $42 : Character:=$3042; // B
        $43 : Character:=$2E43; // C
        $44 : Character:=$2044; // D
        $45 : Character:=$1245; // E
        $46 : Character:=$2146; // F
        $47 : Character:=$2247; // G
        $48 : Character:=$2348; // H
        $49 : Character:=$1749; // I
        $4A : Character:=$244A; // J
        $4B : Character:=$254B; // K
        $4C : Character:=$264C; // L
        $4D : Character:=$324D; // M
        $4E : Character:=$314E; // N
        $4F : Character:=$184F; // O
        $50 : Character:=$1950; // P
        $51 : Character:=$1051; // Q
        $52 : Character:=$1352; // R
        $53 : Character:=$1F53; // S
        $54 : Character:=$1454; // T
        $55 : Character:=$1655; // U
        $56 : Character:=$2F56; // V
        $57 : Character:=$1157; // W
        $58 : Character:=$2D58; // X
        $59 : Character:=$1559; // Y
        $5A : Character:=$2C5A; // Z

        $1B : Character:=$011B; // ESC

        $31 : Character:=$0221; // !  1
        $32 : Character:=$0322; // "  2
        $33 : Character:=$0415; // §  3
        $34 : Character:=$0524; // $  4
        $35 : Character:=$0625; // %  5
        $36 : Character:=$0726; // &  6
        $37 : Character:=$082F; // /  7
        $38 : Character:=$0928; // (  8
        $39 : Character:=$0A29; // )  9
        $30 : Character:=$0B3D; // =  0


        // Character 3. Row
        $BB : Character:=$1B2A; // *

        // Character 4. Row
        $BF : Character:=$2B27; // '

        // Character 5. Row
        $E2 : Character:=$563E; // >
        $BC : Character:=$333B; // ;
        $BE : Character:=$343A; // :
        $BD : Character:=$355F; // _



      else
        Character := $00;
      end; { case Key of }
    end; { if Key<>16 then }
  end; { if Shift=[SSSHIFT] then }


  if Shift = [SSCTRL] then begin
    if Key<>17 then begin

      case Key of

        // Buchstaben CTR-A..CTR-Z
        $41 : Character:=$1E01; // CTR-A
        $42 : Character:=$3002; // CTR-B
        $43 : Character:=$2E03; // CTR-C
        $44 : Character:=$2004; // CTR-D
        $45 : Character:=$1205; // CTR-E
        $46 : Character:=$2106; // CTR-F
        $47 : Character:=$2207; // CTR-G
        $48 : Character:=$2308; // CTR-H
        $49 : Character:=$1709; // CTR-I
        $4A : Character:=$240A; // CTR-J
        $4B : Character:=$250B; // CTR-K
        $4C : Character:=$260C; // CTR-L
        $4D : Character:=$320D; // CTR-M
        $4E : Character:=$310E; // CTR-N
        $4F : Character:=$180F; // CTR-O
        $50 : Character:=$1910; // CTR-P
        $51 : Character:=$1011; // CTR-Q
        $52 : Character:=$1312; // CTR-R
        $53 : Character:=$1F13; // CTR-S
        $54 : Character:=$1414; // CTR-T
        $55 : Character:=$1615; // CTR-U
        $56 : Character:=$2F16; // CTR-V
        $57 : Character:=$1117; // CTR-W
        $58 : Character:=$2D18; // CTR-X
        $59 : Character:=$1519; // CTR-Y
        $5A : Character:=$2C1A; // CTR-Z

      else
        Character := $00;
      end; { case Key of }

    end;
  end; { if Shift=[SSCTRL] then }


  if Shift = [ssAlt] then begin
    if Key<>18 then begin

      case Key of

        // Buchstaben ALT-A..ALT-Z
        $41 : Character:=$1E00; // ALT-A
        $42 : Character:=$3000; // ALT-B
        $43 : Character:=$2E00; // ALT-C
        $44 : Character:=$2000; // ALT-D
        $45 : Character:=$1200; // ALT-E
        $46 : Character:=$2100; // ALT-F
        $47 : Character:=$2200; // ALT-G
        $48 : Character:=$2300; // ALT-H
        $49 : Character:=$1700; // ALT-I
        $4A : Character:=$2400; // ALT-J
        $4B : Character:=$2500; // ALT-K
        $4C : Character:=$2600; // ALT-L
        $4D : Character:=$3200; // ALT-M
        $4E : Character:=$3100; // ALT-N
        $4F : Character:=$1800; // ALT-O
        $50 : Character:=$1900; // ALT-P
        $51 : Character:=$1000; // ALT-Q
        $52 : Character:=$1300; // ALT-R
        $53 : Character:=$1F00; // ALT-S
        $54 : Character:=$1400; // ALT-T
        $55 : Character:=$1600; // ALT-U
        $56 : Character:=$2F00; // ALT-V
        $57 : Character:=$1100; // ALT-W
        $58 : Character:=$2D00; // ALT-X
        $59 : Character:=$1500; // ALT-Y
        $5A : Character:=$2C00; // ALT-Z

        $31 : Character:=$7800; // ALT-1
        $32 : Character:=$7900; // ALT-2
        $33 : Character:=$7A00; // ALT-3
        $34 : Character:=$7B00; // ALT-4
        $35 : Character:=$7C00; // ALT-5
        $36 : Character:=$7D00; // ALT-6
        $37 : Character:=$7E00; // ALT-7
        $38 : Character:=$7F00; // ALT-8
        $39 : Character:=$8000; // ALT-9
        $30 : Character:=$8100; // ALT-0


        $70 : Character:=$6800; // F1
        $71 : Character:=$6900; // F2
        $72 : Character:=$6A00; // F3
        $73 : Character:=$6B00; // F4
        $74 : Character:=$6C00; // F5
        $75 : Character:=$6D00; // F6
        $76 : Character:=$6E00; // F7
        $77 : Character:=$6F00; // F8
        $78 : Character:=$7000; // F9
        $79 : Character:=$7100; // F10
        $7A : Character:=$7200; // F11
        $7B : Character:=$7300; // F12




  //      $3A : Character:=$8200; // ALT-sz
  //      $3B : Character:=$8300; // ALT-´

      else
        Character := $00;
      end; { case Key of }

    end; { if Key<>18 then }
  end; { if Shift=[SSCTRL] then }


  if Character>$00 then begin

   write_key(Character);

  end; { if Character>$00 then }



end; { procedure TForm_CONS.FormKeyDown }





