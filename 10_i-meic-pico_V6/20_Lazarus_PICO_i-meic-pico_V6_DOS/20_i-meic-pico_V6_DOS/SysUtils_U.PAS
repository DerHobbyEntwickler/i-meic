unit SysUtils_U;
{$MODE OBJFPC}


interface


var

  Byte_Dez_String  : String[3];
  DWord_Hex_String : String[8];




  function ByteToChar(BTC_Byte : Byte) : Char;
  function CharToByte(CTB_Char : Char) : Byte;
  function ByteToWord(BTW_Byte : Byte) : Word;
  function LowDWordToWord(DWL_DWord : DWord) : Word;
  function HighDWordToWord(DWL_DWord : DWord) : Word;
  function HighWordToByte(HW_Word : Word) : Byte;
  function LowWordToByte(LW_Word : Word) : Byte;
  function DWordToByte(Pos_in_DWord : Byte;
                     DW2B : DWord) : Byte;
  function bcd2bin(val: Byte): Byte;
  function bin2bcd(val: Byte): Byte;



  (* Zahl zu Dezimal-String *)
  FUNCTION DWordToStr(DS_DWord : DWord) : String;
  FUNCTION WordToStr(DS_Word : Word) : String;
  FUNCTION ByteToStr(BS_Byte : Byte) : String;

  (* Zahl zu HEX-String *)
  FUNCTION ByteToHexStr(b1:Byte) : String;
  FUNCTION WordToHexStr(w1:Word) : String;
  FUNCTION DWordToHexStr(dw1 : DWord) : String;

  (* HEX-String zu Zahl *)
  function HexStrToByte(Hex_String : String) : Byte;
  function HexStrToWord(HS_String : String) : Word;
  FUNCTION HexStrToDWord(HS_String : String) : DWord;

  (* Dezimal-String zu Zahl *)
  FUNCTION StrToDWord(s1_String : String) : DWord;
  FUNCTION StrToWord(s1_String : String) : Word;
  FUNCTION StrToByte(s1_String : String) : Byte;



implementation


CONST
  HexArray : array[0..15] of char='0123456789ABCDEF';
  CR : CHAR = #13;






// ******************************
// ***   Typ-Konvertierung    ***
// ******************************




function ByteToChar(BTC_Byte : Byte) : Char;
begin
  Result:=CHR(BTC_Byte);
end;


function CharToByte(CTB_Char : Char) : Byte;
begin
  Result:=ORD(CTB_Char);
end;





function ByteToWord(BTW_Byte : Byte) : Word;
var
  BTW_Word : Word;
begin
  BTW_Word:=0;
  BTW_Word:=BTW_Byte;
  Result:=BTW_Word;
end;







function LowDWordToWord(DWL_DWord : DWord) : Word;
var
  RES_Word : Word;
begin
  RES_Word:=LO(DWL_DWord);
  Result:=RES_Word;
end;



function HighDWordToWord(DWL_DWord : DWord) : Word;
var
  RES_Word : Word;
begin
  RES_Word:=HI(DWL_DWord);
  Result:=RES_Word;
end;





function HighWordToByte(HW_Word : Word) : Byte;
var
  HW_Byte : Byte;
begin
  HW_Byte:=HI(HW_Word);
  Result:=HW_Byte;
end;




function LowWordToByte(LW_Word : Word) : Byte;
var
  LW_Byte : Byte;
begin
  LW_Byte:=LO(LW_Word);
  Result:=LW_Byte;
end;




function DWordToByte(Pos_in_DWord : Byte;
                     DW2B : DWord) : Byte;
var
  W1 : Word;
  B1 : Byte;
begin

  case Pos_in_DWord of
    0: begin
         W1:=LO(DW2B);
         B1:=LO(W1);
       end;
    1: begin
         W1:=LO(DW2B);
         B1:=HI(W1);
       end;
    2: begin
         W1:=HI(DW2B);
         B1:=LO(W1);
       end;
    3: begin
         W1:=HI(DW2B);
         B1:=HI(W1);
       end;
  else
    B1:=0;
  end;

  Result:=B1;

end; // function DWordToByte




// BCD zu BIN



  function bcd2bin(val: Byte): Byte;
  begin
    Result := val - 6 * (val shr 4);
  end;


  function bin2bcd(val: Byte): Byte;
  begin
    Result := val + 6 * (val div 10);
  end;




// **************************************
// ***  INT (Byte,Word,DWord) to STR  ***
// **************************************




(* Zahl zu Dezimal-String *)


  { DWord von 0 ... 4.294.967.295 }
  FUNCTION DWordToStr(DS_DWord : DWord) : String;
  VAR
    st1 : String;
    dw1, Faktor : DWord;
    w1 : Word;
    b1 : Byte;
    c1 : Char;
    ZahlLesen : Boolean;
  BEGIN

    st1:='';
    Faktor:=1000000000;
    ZahlLesen:=false;

    WHILE Faktor>1 DO BEGIN

      dw1:=DS_DWord div Faktor;
      DS_DWord:=DS_DWord mod Faktor;
      Faktor:=Faktor div 10;

      IF (dw1>0) or (ZahlLesen) THEN BEGIN
        w1:=Word(dw1);
        b1:=Byte(w1);
        c1:=Char(b1+$30);
        st1:=st1+c1;
        ZahlLesen:=true;
      END;

    END;

 
    w1:=Word(DS_DWord);
    b1:=Byte(w1);
    c1:=Char(b1+$30);
    st1:=st1+c1;
  

    DWordToStr:=st1;

  END; { function DWordToStr }





{ Word von 0 ... 65.535 }
FUNCTION WordToStr(DS_Word : Word) : String;
VAR
  st1 : String;
  w1, Faktor : Word;
  b1 : Byte;
  c1 : Char;
  ZahlLesen : Boolean;
BEGIN

  st1:='';
  Faktor:=10000;
  ZahlLesen:=false;

  WHILE Faktor>1 DO BEGIN

    w1:=DS_Word div Faktor;
    DS_Word:=DS_Word mod Faktor;
    Faktor:=Faktor div 10;

    IF (w1>0) or (ZahlLesen) THEN BEGIN
      b1:=Byte(w1);
      c1:=Char(b1+$30);
      st1:=st1+c1;
      ZahlLesen:=true;
    END;

  END;

  b1:=Byte(DS_Word);
  c1:=Char(b1+$30);
  st1:=st1+c1;

  WordToStr:=st1;

END; { function WordToStr }





{ Word von 0 ... 255 }
FUNCTION ByteToStr(BS_Byte : Byte) : String;
VAR
  st1 : String;
  b1, Faktor : Byte;
  c1 : Char;
  ZahlLesen : Boolean;
BEGIN

  st1:='';
  Faktor:=100;
  ZahlLesen:=false;

  WHILE Faktor>1 DO BEGIN

    b1:=BS_Byte div Faktor;
    BS_Byte:=BS_Byte mod Faktor;
    Faktor:=Faktor div 10;

    IF (b1>0) or (ZahlLesen) THEN BEGIN
      c1:=Char(b1+$30);
      st1:=st1+c1;
      ZahlLesen:=true;
    END;

  END;

  
  b1:=Byte(BS_Byte);
  c1:=Char(b1+$30);
  st1:=st1+c1;
  

  ByteToStr:=st1;

END; { function ByteToStr }





(* Zahl zu HEX-String *)

FUNCTION ByteToHexStr(b1:Byte) : String;
BEGIN
  ByteToHexStr:=HexArray[(b1 shr 4) and $0F]+HexArray[b1 and $0F];
END;



FUNCTION WordToHexStr(w1:Word) : String;
var
  HI_Word, LO_Word : Byte;
  WTH_String : String;
BEGIN

  HI_Word:=HI(w1);
  LO_Word:=LO(w1);

  WTH_String:=HexArray[(HI_Word shr 4) and $0F]+HexArray[HI_Word and $0F];
  WTH_String:=WTH_String+HexArray[(LO_Word shr 4) and $0F]+HexArray[LO_Word and $0F];

  WordToHexStr:=WTH_String;
END;



FUNCTION DWordToHexStr(dw1 : DWord) : String;
BEGIN
  DWordToHexStr:=WordToHexStr(dw1 shr 16)+WordToHexStr((dw1 and $0000FFFF));
END;






// **************************************
// ***  STR to INT (Byte,Word,DWord)  ***
// **************************************


(* Hex-String zu Zahl *)

function HexStrToByte(Hex_String : String) : Byte;
var
  HexLow : Byte;
  HexHigh : Byte;
  S2B : Byte;
  c1 : Char;
begin

  while Length(Hex_String)<2 do begin
    Hex_String:='0'+Hex_String;
  end;

  c1:=Hex_String[1];
  HexHigh:=CharToByte(c1);
  HexHigh:=HexHigh-48;
  if HexHigh>9 then
    HexHigh:=HexHigh-7;

  HexHigh:=HexHigh shl 4;

  c1:=Hex_String[2];
  HexLow:=CharToByte(c1);
  HexLow:=HexLow-48;
  if HexLow>9 then
    HexLow:=HexLow-7;

  S2B:=HexHigh+HexLow;

  RESULT:=S2B;

end; // HexStrToByte





function HexStrToWord(HS_String : String) : Word;
var
  HS_Word : Word;
begin

  while Length(HS_String)<4 do begin
    HS_String:='0'+HS_String;
  end;

  HS_Word:=256*HexStrToByte(HS_String[1]+HS_String[2]);
  HS_Word:=HS_Word+HexStrToByte(HS_String[3]+HS_String[4]);

  Result:=HS_Word;

end; // function HexStringToWord






FUNCTION HexStrToDWord(HS_String : String) : DWord;
VAR
 w1, x : word;
 dw1 : DWord;
 c1 : Char;
BEGIN
 dw1:=0;
 FOR x:=1 to Length(HS_String) DO BEGIN
   c1:=HS_String[x];
   CASE c1 OF
     '0'..'9'          : dw1:=(dw1 shl 4)+(ord(c1) and 15);
     'a'..'f','A'..'F' : dw1:=(dw1 shl 4)+((ord(c1) and 15)+9);
   END;
 END;
 HexStrToDWord:=dw1;
END;







(* Dezimal-String zu Zahl *)


  FUNCTION StrToDWord(s1_String : String) : DWord;
  VAR
    dw1, dw2, Faktor : DWord;
    ch1 : Char;
  BEGIN

    dw1:=0;
    Faktor:=1;

    WHILE Length(s1_String)>0 DO BEGIN

      ch1:=s1_String[Length(s1_String)];
      delete(s1_String,Length(s1_String),1);

      IF ch1 IN ['0','1','2','3','4','5','6','7','8','9'] THEN BEGIN
        dw2:=Byte(ch1)-Byte('0');
        dw1:=dw1+(dw2*Faktor);
        Faktor:=Faktor*10;
      END
      ELSE
        s1_String:='';

    END; { if Length(s1_String)>0 then }

    StrToDWord:=dw1;

  END; { function StrToDWord }





FUNCTION StrToWord(s1_String : String) : Word;
VAR
  w1, w2, Faktor : Word;
  ch1 : Char;
BEGIN

  w1:=0;
  Faktor:=1;

  WHILE Length(s1_String)>0 DO BEGIN

    ch1:=s1_String[Length(s1_String)];
    delete(s1_String,Length(s1_String),1);

    IF ch1 IN ['0','1','2','3','4','5','6','7','8','9'] THEN BEGIN
      w2:=Byte(ch1)-Byte('0');
      w1:=w1+(w2*Faktor);
      Faktor:=Faktor*10;
    END
    ELSE
      s1_String:='';

  END; { if Length(s1_String)>0 then }

  StrToWord:=w1;

END; { function StrToWord }




FUNCTION StrToByte(s1_String : String) : Byte;
VAR
  b1, b2, Faktor : Byte;
  ch1 : Char;
BEGIN

  b1:=0;
  Faktor:=1;

  WHILE Length(s1_String)>0 DO BEGIN

    ch1:=s1_String[Length(s1_String)];
    delete(s1_String,Length(s1_String),1);

    IF ch1 IN ['0','1','2','3','4','5','6','7','8','9'] THEN BEGIN
      b2:=Byte(ch1)-Byte('0');
      b1:=b1+(b2*Faktor);
      Faktor:=Faktor*10;
    END
    ELSE
      s1_String:='';

  END; { if Length(s1_String)>0 then }

  StrToByte:=b1;

END; { function StrToByte }







end.

